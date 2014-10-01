# encoding: utf-8

require 'cucumber/formatter/console'
require 'cucumber/formatter/io'


require 'fileutils'
require 'cucumber/formatter/console'
require 'cucumber/formatter/io'
require 'gherkin/formatter/escaping'

module Cucumber
  module Formatter
    # Formatter for Sharetribe
    #
    # Features:
    # - Less output:
    #   - Prints dots when running steps
    #   - Prints one line with checkmark when scenario is finnished
    # - Shows errors immediately (perfect for Travis)
    # - Shows verbose error information
    #
    # The formatter is a quick-n-dirty hack. It's a copy-paste from Cucumber's "pretty" formatter.
    #
    class Sharetribe
      include FileUtils
      include Console
      include Io
      include Gherkin::Formatter::Escaping
      attr_writer :indent
      attr_reader :runtime

      def initialize(runtime, path_or_io, options)
        @runtime, @io, @options = runtime, ensure_io(path_or_io, "sharetribe"), options
        @exceptions = []
        @indent = 0
        @prefixes = options[:prefixes] || {}
        @delayed_messages = []
        @buffer = []
      end

      def before_features(features)
        print_profile_information
      end

      def after_features(features)
        print_summary(features)
      end

      def before_feature(feature)
        @exceptions = []
        @indent = 0
      end

      def comment_line(comment_line)
        buffer_puts(comment_line.indent(@indent))
      end

      # def after_tags(tags)
      #   if @indent == 1
      #     @io.puts
      #     @io.flush
      #   end
      # end

      # def tag_name(tag_name)
      #   tag = format_string(tag_name, :tag).indent(@indent)
      #   # @io.print(tag)
      #   # @io.flush
      #   @indent = 1
      # end

      def feature_name(keyword, name)
        # @io.puts("#{keyword}: #{name}")
        # @io.puts
        # @io.flush
      end

      def before_feature_element(feature_element)
        @indent = 2
        @scenario_indent = 2
      end

      def after_feature_element(feature_element)
        @io.print("\r")

        if @status == :passed
          @io.print(format_string("✔", :passed))
          print_feature_element_name(nil, @scenario_name, @scenario_file_colon_line, nil, :passed)
          buffer_clear()
        else
          @io.print(format_string("✘", :failed))
          print_feature_element_name(nil, @scenario_name, @scenario_file_colon_line, nil, :failed)
          buffer_flush()
          @io.puts
        end
      end

      def before_background(background)
        @indent = 2
        @scenario_indent = 2
        @in_background = true
      end

      def after_background(background)
        # print_messages
        @in_background = nil
        # @io.puts
        # @io.flush
      end

      def background_name(keyword, name, file_colon_line, source_indent)
        buffer_print_feature_element_name(keyword, name, file_colon_line, source_indent)
      end

      def before_examples_array(examples_array)
        @indent = 4
        @io.puts
        @visiting_first_example_name = true
      end

      def examples_name(keyword, name)
        buffer_puts unless @visiting_first_example_name
        @visiting_first_example_name = false
        names = name.strip.empty? ? [name.strip] : name.split("\n")
        buffer_puts("    #{keyword}: #{names[0]}")
        names[1..-1].each {|s| buffer_puts "      #{s}" } unless names.empty?
        @indent = 6
        @scenario_indent = 6
      end

      def before_outline_table(outline_table)
        # @table = outline_table
      end

      def after_outline_table(outline_table)
        @table = nil
        @indent = 4
      end

      def scenario_name(keyword, name, file_colon_line, source_indent)
        @scenario_name = name
        @scenario_file_colon_line = file_colon_line
      end

      def before_step(step)
        @current_step = step
        @indent = 6
        # print_messages
      end

      # rubocop:disable ParameterLists
      def before_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line)
        @hide_this_step = false
        if exception
          if @exceptions.include?(exception)
            @hide_this_step = true
            return
          end
          @exceptions << exception
        end
        if status != :failed && @in_background ^ background
          @hide_this_step = true
          return
        end

        @status = status
      end
      # rubocop:enable ParameterLists

      def step_name(keyword, step_match, status, source_indent, background, file_colon_line)
        return if @hide_this_step
        source_indent = nil unless @options[:source]
        name_to_report = format_step(keyword, step_match, status, source_indent)

        if !background && status == :passed
          @io.print(format_string(".", :passed))
        end

        buffer_puts(name_to_report.indent(@scenario_indent + 2))
        print_messages
      end

      def doc_string(string)
        # return if @options[:no_multiline] || @hide_this_step
        # s = %{"""\n#{string}\n"""}.indent(@indent)
        # s = s.split("\n").map{|l| l =~ /^\s+$/ ? '' : l}.join("\n")
        # @io.puts(format_string(s, @current_step.status))
        # @io.flush
      end

      def exception(exception, status)
        return if @hide_this_step
        print_messages
        buffer_print_exception(exception, status, @indent)
      end

      def buffer_print_exception(e, status, indent)
        message = "#{e.message} (#{e.class})"
        if ENV['CUCUMBER_TRUNCATE_OUTPUT']
          message = linebreaks(message, ENV['CUCUMBER_TRUNCATE_OUTPUT'].to_i)
        end

        string = "#{message}\n#{e.backtrace.join("\n")}".indent(indent)
        buffer_puts(format_string(string, status))
      end

      def before_multiline_arg(multiline_arg)
        # return if @options[:no_multiline] || @hide_this_step
        # @table = multiline_arg
      end

      def after_multiline_arg(multiline_arg)
        @table = nil
      end

      def before_table_row(table_row)
        return if !@table || @hide_this_step
        @col_index = 0
        buffer_print '  |'.indent(@indent-2)
      end

      def after_table_row(table_row)
        return if !@table || @hide_this_step
        print_table_row_messages
        buffer_puts
        if table_row.exception && !@exceptions.include?(table_row.exception)
          print_exception(table_row.exception, table_row.status, @indent)
        end
      end

      def after_table_cell(cell)
        return unless @table
        @col_index += 1
      end

      def table_cell_value(value, status)
        return if !@table || @hide_this_step
        status ||= @status || :passed
        width = @table.col_width(@col_index)
        cell_text = escape_cell(value.to_s || '')
        padded = cell_text + (' ' * (width - cell_text.unpack('U*').length))
        prefix = cell_prefix(status)
        buffer_print(' ' + format_string("#{prefix}#{padded}", status) + ::Cucumber::Term::ANSIColor.reset(" |"))
      end

      private

      def print_feature_element_name(_, name, file_colon_line, _, status)
        @io.puts if @scenario_indent == 6
        names = name.empty? ? [name] : name.split("\n")
        line = "#{format_string(names[0], status)}".indent(@scenario_indent)
        @io.print(line)
        if @options[:source]
          line_comment = " # #{file_colon_line}"
          @io.print(format_string(line_comment, :comment))
        end
        @io.puts
        names[1..-1].each {|s| @io.puts "    #{s}"}
        # @io.print((0..(@scenario_indent - 1)).collect { |_| " " }.join() )
      end

      def buffer_print_feature_element_name(keyword, name, file_colon_line, source_indent)
        buffer_puts if @scenario_indent == 6
        names = name.empty? ? [name] : name.split("\n")
        line = "#{keyword}: #{names[0]}".indent(@scenario_indent)
        buffer_print(line)
        if @options[:source]
          line_comment = " # #{file_colon_line}"
          buffer_print(format_string(line_comment, :comment))
        end
        buffer_puts
        names[1..-1].each {|s| buffer_puts "    #{s}"}
      end

      def cell_prefix(status)
        @prefixes[status]
      end

      def print_summary(features)
        print_stats(features, @options)
        print_snippets(@options)
        print_passing_wip(@options)
      end

      def buffer_print(line = "")
        @buffer << [:print, line]
      end

      def buffer_puts(line = "")
        @buffer << [:puts, line]
      end

      def buffer_flush()
        @buffer.each { |(act, line)|
          if act == :print
            @io.print(line)
          elsif act == :puts
            @io.puts(line)
          end
        }
        @io.flush
        @buffer = []
      end

      def buffer_clear
        @buffer = []
      end
    end
  end
end
