# frozen_string_literal: true

require 'digest/sha1'

# rubocop:disable Metrics/ClassLength
module RuboCop
  module AST
    # ProcessedSource contains objects which are generated by Parser
    # and other information such as disabled lines for cops.
    # It also provides a convenient way to access source lines.
    class ProcessedSource
      # @api private
      STRING_SOURCE_NAME = '(string)'

      INVALID_LEVELS = %i[error fatal].freeze
      private_constant :INVALID_LEVELS

      PARSER_ENGINES = %i[parser_whitequark parser_prism].freeze
      private_constant :PARSER_ENGINES

      attr_reader :path, :buffer, :ast, :comments, :tokens, :diagnostics,
                  :parser_error, :raw_source, :ruby_version, :parser_engine

      def self.from_file(path, ruby_version, parser_engine: :parser_whitequark)
        file = File.read(path, mode: 'rb')
        new(file, ruby_version, path, parser_engine: parser_engine)
      end

      def initialize(source, ruby_version, path = nil, parser_engine: :parser_whitequark)
        unless PARSER_ENGINES.include?(parser_engine)
          raise ArgumentError, 'The keyword argument `parser_engine` accepts ' \
                               "`parser` or `parser_prism`, but `#{parser_engine}` was passed."
        end

        # Defaults source encoding to UTF-8, regardless of the encoding it has
        # been read with, which could be non-utf8 depending on the default
        # external encoding.
        (+source).force_encoding(Encoding::UTF_8) unless source.encoding == Encoding::UTF_8

        @raw_source = source
        @path = path
        @diagnostics = []
        @ruby_version = ruby_version
        @parser_engine = parser_engine
        @parser_error = nil

        parse(source, ruby_version, parser_engine)
      end

      def ast_with_comments
        return if !ast || !comments

        @ast_with_comments ||= Parser::Source::Comment.associate_by_identity(ast, comments)
      end

      # Returns the source lines, line break characters removed, excluding a
      # possible __END__ and everything that comes after.
      def lines
        @lines ||= begin
          all_lines = @buffer.source_lines
          last_token_line = tokens.any? ? tokens.last.line : all_lines.size
          result = []
          all_lines.each_with_index do |line, ix|
            break if ix >= last_token_line && line == '__END__'

            result << line
          end
          result
        end
      end

      def [](*args)
        lines[*args]
      end

      def valid_syntax?
        return false if @parser_error

        @diagnostics.none? { |d| INVALID_LEVELS.include?(d.level) }
      end

      # Raw source checksum for tracking infinite loops.
      def checksum
        Digest::SHA1.hexdigest(@raw_source)
      end

      # @deprecated Use `comments.each`
      def each_comment(&block)
        comments.each(&block)
      end

      # @deprecated Use `comment_at_line`, `each_comment_in_lines`, or `comments.find`
      def find_comment(&block)
        comments.find(&block)
      end

      # @deprecated Use `tokens.each`
      def each_token(&block)
        tokens.each(&block)
      end

      # @deprecated Use `tokens.find`
      def find_token(&block)
        tokens.find(&block)
      end

      def file_path
        buffer.name
      end

      def blank?
        ast.nil?
      end

      # @return [Comment, nil] the comment at that line, if any.
      def comment_at_line(line)
        comment_index[line]
      end

      # @return [Boolean] if the given line number has a comment.
      def line_with_comment?(line)
        comment_index.include?(line)
      end

      # Enumerates on the comments contained with the given `line_range`
      def each_comment_in_lines(line_range)
        return to_enum(:each_comment_in_lines, line_range) unless block_given?

        line_range.each do |line|
          if (comment = comment_index[line])
            yield comment
          end
        end
      end

      # @return [Boolean] if any of the lines in the given `source_range` has a comment.
      # Consider using `each_comment_in_lines` instead
      def contains_comment?(source_range)
        each_comment_in_lines(source_range.line..source_range.last_line).any?
      end
      # @deprecated use contains_comment?
      alias commented? contains_comment?

      # @deprecated Use `each_comment_in_lines`
      # Should have been called `comments_before_or_at_line`. Doubtful it has of any valid use.
      def comments_before_line(line)
        each_comment_in_lines(0..line).to_a
      end

      def start_with?(string)
        return false if self[0].nil?

        self[0].start_with?(string)
      end

      def preceding_line(token)
        lines[token.line - 2]
      end

      def current_line(token)
        lines[token.line - 1]
      end

      def following_line(token)
        lines[token.line]
      end

      def line_indentation(line_number)
        lines[line_number - 1]
          .match(/^(\s*)/)[1]
          .to_s
          .length
      end

      def tokens_within(range_or_node)
        begin_index = first_token_index(range_or_node)
        end_index = last_token_index(range_or_node)
        sorted_tokens[begin_index..end_index]
      end

      def first_token_of(range_or_node)
        sorted_tokens[first_token_index(range_or_node)]
      end

      def last_token_of(range_or_node)
        sorted_tokens[last_token_index(range_or_node)]
      end

      # The tokens list is always sorted by token position, except for cases when heredoc
      # is passed as a method argument. In this case tokens are interleaved by
      # heredoc contents' tokens.
      def sorted_tokens
        # Use stable sort.
        @sorted_tokens ||= tokens.sort_by.with_index { |token, i| [token.begin_pos, i] }
      end

      private

      def comment_index
        @comment_index ||= {}.tap do |hash|
          comments.each { |c| hash[c.location.line] = c }
        end
      end

      def parse(source, ruby_version, parser_engine)
        buffer_name = @path || STRING_SOURCE_NAME
        @buffer = Parser::Source::Buffer.new(buffer_name, 1)

        begin
          @buffer.source = source
        rescue EncodingError => e
          @parser_error = e
          @ast = nil
          @comments = []
          @tokens = []
          return
        end

        @ast, @comments, @tokens = tokenize(create_parser(ruby_version, parser_engine))
      end

      def tokenize(parser)
        begin
          ast, comments, tokens = parser.tokenize(@buffer)
          ast ||= nil # force `false` to `nil`, see https://github.com/whitequark/parser/pull/722
        rescue Parser::SyntaxError
          # All errors are in diagnostics. No need to handle exception.
          comments = []
          tokens = []
        end

        ast&.complete!
        tokens.map! { |t| Token.from_parser_token(t) }

        [ast, comments, tokens]
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      def parser_class(ruby_version, parser_engine)
        case parser_engine
        when :parser_whitequark
          case ruby_version
          when 1.9
            require 'parser/ruby19'
            Parser::Ruby19
          when 2.0
            require 'parser/ruby20'
            Parser::Ruby20
          when 2.1
            require 'parser/ruby21'
            Parser::Ruby21
          when 2.2
            require 'parser/ruby22'
            Parser::Ruby22
          when 2.3
            require 'parser/ruby23'
            Parser::Ruby23
          when 2.4
            require 'parser/ruby24'
            Parser::Ruby24
          when 2.5
            require 'parser/ruby25'
            Parser::Ruby25
          when 2.6
            require 'parser/ruby26'
            Parser::Ruby26
          when 2.7
            require 'parser/ruby27'
            Parser::Ruby27
          when 2.8, 3.0
            require 'parser/ruby30'
            Parser::Ruby30
          when 3.1
            require 'parser/ruby31'
            Parser::Ruby31
          when 3.2
            require 'parser/ruby32'
            Parser::Ruby32
          when 3.3
            require 'parser/ruby33'
            Parser::Ruby33
          when 3.4
            require 'parser/ruby34'
            Parser::Ruby34
          else
            raise ArgumentError, "RuboCop found unknown Ruby version: #{ruby_version.inspect}"
          end
        when :parser_prism
          begin
            require 'prism'
          rescue LoadError
            warn "Error: Unable to load Prism. Add `gem 'prism'` to your Gemfile."
            exit!
          end

          case ruby_version
          when 3.3
            require 'prism/translation/parser33'
            Prism::Translation::Parser33
          when 3.4
            require 'prism/translation/parser34'
            Prism::Translation::Parser34
          else
            raise ArgumentError, 'RuboCop supports target Ruby versions 3.3 and above with Prism. ' \
                                 "Specified target Ruby version: #{ruby_version.inspect}"
          end
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength

      def create_parser(ruby_version, parser_engine)
        builder = RuboCop::AST::Builder.new

        parser_class(ruby_version, parser_engine).new(builder).tap do |parser|
          # On JRuby there's a risk that we hang in tokenize() if we
          # don't set the all errors as fatal flag. The problem is caused by a bug
          # in Racc that is discussed in issue #93 of the whitequark/parser
          # project on GitHub.
          parser.diagnostics.all_errors_are_fatal = (RUBY_ENGINE != 'ruby')
          parser.diagnostics.ignore_warnings = false
          parser.diagnostics.consumer = lambda do |diagnostic|
            @diagnostics << diagnostic
          end
        end
      end

      def first_token_index(range_or_node)
        begin_pos = source_range(range_or_node).begin_pos
        sorted_tokens.bsearch_index { |token| token.begin_pos >= begin_pos }
      end

      def last_token_index(range_or_node)
        end_pos = source_range(range_or_node).end_pos
        sorted_tokens.bsearch_index { |token| token.end_pos >= end_pos }
      end

      def source_range(range_or_node)
        if range_or_node.respond_to?(:source_range)
          range_or_node.source_range
        else
          range_or_node
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
