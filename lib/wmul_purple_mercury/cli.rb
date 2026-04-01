require "dry/cli"
require "semantic_logger"
require_relative "../wmul_purple_mercury"

module WMULPurpleMercury
  VERSION = "0.0.1"

  module CLI
    module Commands
      extend Dry::CLI::Registry

      class Version < Dry::CLI::Command
        desc "Print the program version number and quit."

        def call(*)
          puts WMULPurpleMercury::VERSION
        end
      end

      class BuildAsciidocSourceForAntora < Dry::CLI::Command
        include SemanticLogger::Loggable

        desc "Recursively iterates through all of the asciidoc files inside --asciidoc_source_folder , runs 
        asciidoc-reducer on them, and saves the output into --antora_build_folder. Files with the middle suffix .src 
        .prebuild and .pdf are not reduced, although they can be included in the other files using the asciidoc 
        include[] directive." 

        option :asciidoc_source_folder, default: :emptyoption, 
          desc: "The folder containing all of the asciidoc files to be reduced."

        option :antora_build_folder, default: :emptyoption, 
          desc: "The location of the antora /antora/modules/ROOT/pages/ folder."

        option :create_build_folder, default: false, type: :boolean, 
          desc: "If --antora_build_folder does not already exist, create it."

        option :log_name, default: :emptyoption, desc: "The path to the log file."

        option :log_level, default: 30, type: :integer, 
          desc: "The log level: 0: Trace, 10: Debug, 20: Info, 30: Warning, 40: Error, 50: Fatal. Intermediate values 
                (E.G. 32) are permitted, but will essentially be rounded down (E.G. Entering 32 is the same as entering 
                30. Values beyond the 0-50 limit will be clamped to those limits. Logging messages lower than the log 
                level will not be written to the log. E.G. If 30 is input, then all Debug, Info, and Trace messages 
                will be silenced."

        def call(**options)
          begin
            WMULPurpleMercury::CLI::LoggerSetup.setup_logger(options)
          rescue ArgumentError => e
            puts e.message
            return
          end
          
          logger.info("With #{options}")
          asciidoc_source_folder = options.fetch(:asciidoc_source_folder)
          begin
            WMULPurpleMercury::CLI::Validators.validate_source_folder(asciidoc_source_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --asciidoc_source_folder #{e.message}")
            return
          end
          create_build_folder = options.fetch(:create_build_folder)
          antora_build_folder = options.fetch(:antora_build_folder)
          begin
            WMULPurpleMercury::CLI::Validators.validate_build_folder(antora_build_folder, create_build_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --antora_build_folder #{e.message}")
            return
          end
          WMULPurpleMercury::Build.build_asciidoc_source_for_antora(asciidoc_source_folder, antora_build_folder)
        end
      end
    end

    module Validators
      include SemanticLogger::Loggable 
      def self.validate_source_folder(source_folder)
        logger.info("With #{source_folder}")
        if source_folder == :emptyoption
          raise ArgumentError.new("is a required argument.")
        end
        unless File.exist?(source_folder)
          raise ArgumentError.new("#{source_folder} does not exist.")
        end
        unless File.directory?(source_folder)
          raise ArgumentError.new("#{source_folder} is not a folder.")
        end
        unless File.readable?(source_folder)
          raise ArgumentError.new("#{source_folder} is not readable.")
        end
      end


      def self.validate_build_folder(build_folder, create_build_folder)
        logger.info("With #{build_folder}")
        if build_folder == :emptyoption
          raise ArgumentError.new("is a required argument.")
        end
        unless File.exist?(build_folder)
          if create_build_folder
            logger.info("Creating build folder.")
            Dir.mkdir(build_folder, 0644)
          else
            raise ArgumentError.new("#{build_folder} does not exist. It needs to be created or the 
                                    --create_build_folder flag needs to be set.")            
          end
        end
        unless File.directory?(build_folder)
          raise ArgumentError.new("#{build_folder} is not a folder.")
        end
        unless File.writable?(build_folder)
          raise ArgumentError.new("#{build_folder} is not writable.")
        end
      end


      def self.validate_log_level(log_level)
        begin
          log_level = Integer(log_level)
          if log_level < 0
            log_level = 0
          elsif log_level > 50
            log_level = 50
          end
          return log_level
        rescue TypeError, ArgumentError
          raise ArgumentError.new("The --log_level option was given as #{log_level} , which is not a valid integer.")
        end
      end


      def self.validate_log_name(log_name)
        unless File.writable?(log_name)
          raise ArgumentError.new("#{log_name} is not writable.")
        end
      end
    end

    module LoggerSetup
      def self.setup_logger(options)
        log_level = options.fetch(:log_level)
        log_level = WMULPurpleMercury::CLI::Validators.validate_log_level(log_level)
        log_level = convert_log_level_integer_to_symbol(log_level)
        SemanticLogger.default_level = log_level

        log_name = options.fetch(:log_name)
        if log_name == :emptyoption
          SemanticLogger.add_appender(io: $stderr)
        else
          WMULPurpleMercury::CLI::Validators.validate_log_name(log_name)
          SemanticLogger.add_appender(file_name: log_name, formatter: :color)
          SemanticLogger.add_appender(io: $stderr, level: :error)
        end 
      end


      def self.convert_log_level_integer_to_symbol(log_level)
        if log_level < 10
          return :trace
        elsif log_level < 20
          return :debug
        elsif log_level < 30
          return :info
        elsif log_level < 40
          return :warn
        elsif log_level < 50
          return :error
        else
          return :fatal
        end
      end
    end
  end
end

WMULPurpleMercury::CLI::Commands.register "build_asciidoc_source_for_antora", WMULPurpleMercury::CLI::Commands::BuildAsciidocSourceForAntora
WMULPurpleMercury::CLI::Commands.register "version",  WMULPurpleMercury::CLI::Commands::Version
WMULPurpleMercury::CLI::Commands.register "v",  WMULPurpleMercury::CLI::Commands::Version

Dry::CLI.new(WMULPurpleMercury::CLI::Commands).call
