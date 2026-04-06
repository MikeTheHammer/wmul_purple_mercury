require "dry/cli"
require "semantic_logger"
require_relative "../wmul_purple_mercury"

module WMULPurpleMercury
  VERSION = "0.0.8"

  module CLI
    module Commands
      extend Dry::CLI::Registry

      # Generic Commands

      class Version < Dry::CLI::Command
        desc "Print the program version number and quit."

        def call(*)
          puts WMULPurpleMercury::VERSION
        end
      end

      # Common Setup

      class CreateSymlinksForBuild < Dry::CLI::Command
        include SemanticLogger::Loggable

        desc "Create the symlinks to the images/ and attachments/ folders from the build folders as appropriate for the 
        specific components, license and color. E.G. point ./antora/modules/ROOT/images to ./images/sa/color to build 
        the antora version of this document using share-alike color images."

        option :license, default: "nd", values: %w[nd sa], desc: "Which set of images to use, either those for the 
          Share-Alike version or for the No-Derivative version."

        option :color, default: "color", values: %w[color grayscale], desc: "Which set of images to use, either those 
          for the Color version or for the Grayscale version."

        option :build_root, default: "./antora/modules/ROOT", desc: "The build root where the symlinks will originate.
          E.G. ./antora/modules/ROOT"

        option :create_missing_folders, default: false, type: :boolean, 
          desc: "If any of the intermediate folders do not already exist, create them."

        option :images_root, default: "./images", desc: "The root folder of the images. E.G. ./images"

        option :attachments_root, default: "./attachments", desc: "The root folder of the attachments. E.G. 
          ./attachments"

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

          license = options.fetch(:license)
          begin
            license = WMULPurpleMercury::CLI::Validators.validate_license(license)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --license #{e.message}")
          end

          color = options.fetch(:color)
          begin
            color = WMULPurpleMercury::CLI::Validators.validate_color(color)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --color #{e.message}")
          end

          create_missing_folders = options.fetch(:create_missing_folders)
          build_root = options.fetch(:build_root)
          begin
            build_root = WMULPurpleMercury::CLI::Validators.validate_build_folder(build_root, create_missing_folders)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --build_root #{e.message}")
            return
          end

          images_root = options.fetch(:images_root)
          begin
            images_root = WMULPurpleMercury::CLI::Validators.validate_build_folder(images_root, create_missing_folders)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --images_root #{e.message}")
            return
          end

          attachments_root = options.fetch(:attachments_root)
          begin
            attachments_root = WMULPurpleMercury::CLI::Validators.validate_build_folder(attachments_root, create_missing_folders)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --attachments_root #{e.message}")
            return
          end
          WMULPurpleMercury::Setup.create_symlinks_for_build(license, color, build_root, images_root, attachments_root)

        end
      end


      class CreateSymlinksForCommonItems < Dry::CLI::Command
        include SemanticLogger::Loggable

        desc "Create the symlinks within the images/ and attachments/ folders from the more specific folders to the 
        common folders. E.G. point ./images/sa/color/common_color to ./images/sa/common_color . This permits common 
        items to be shared between build types."

        option :create_missing_folders, default: false, type: :boolean, 
          desc: "If any of the intermediate folders do not already exist, create them."

        option :images_root, default: "./images", desc: "The root folder of the images. E.G. ./images"

        option :attachments_root, default: "./attachments", desc: "The root folder of the attachments. E.G. 
          ./attachments"

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

          create_missing_folders = options.fetch(:create_missing_folders)

          images_root = options.fetch(:images_root)
          begin
            images_root = WMULPurpleMercury::CLI::Validators.validate_build_folder(images_root, create_missing_folders)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --images_root #{e.message}")
            return
          end

          attachments_root = options.fetch(:attachments_root)
          begin
            attachments_root = WMULPurpleMercury::CLI::Validators.validate_build_folder(attachments_root, create_missing_folders)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --attachments_root #{e.message}")
            return
          end
          WMULPurpleMercury::Setup.create_symlinks_for_common_items(images_root, attachments_root)
        end
      end


      class CleanBuildFolder < Dry::CLI::Command
        include SemanticLogger::Loggable

        desc "Deletes and re-creates a build folder." 

        option :build_folder, default: :emptyoption, 
          desc: "The folder to be deleted and re-created."

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
          build_folder = options.fetch(:build_folder)
          begin
            build_folder = WMULPurpleMercury::CLI::Validators.validate_build_folder(build_folder, true)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --build_folder #{e.message}")
            return
          end
          WMULPurpleMercury::Setup.clean_build_folder(build_folder)
        end
      end


      class CopyRenderedItems < Dry::CLI::Command
        include SemanticLogger::Loggable

        desc "Copies all of the rendered files from the renders folder to their final destination." 

        option :renders_folder, default: :emptyoption, 
          desc: "The folder containing all of the rendered files."

        option :destination_folder, default: :emptyoption, 
          desc: "The final destination of the rendered files."

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
          renders_folder = options.fetch(:renders_folder)
          begin
            renders_folder = WMULPurpleMercury::CLI::Validators.validate_source_folder(renders_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --renders_folder #{e.message}")
            return
          end
          destination_folder = options.fetch(:destination_folder)
          begin
            destination_folder = WMULPurpleMercury::CLI::Validators.validate_build_folder(destination_folder, true)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --destination_folder #{e.message}")
            return
          end
          WMULPurpleMercury::Setup.copy_rendered_items(renders_folder, destination_folder)
        end
      end


      # Antora

      class BuildAsciidocSourceForAntora < Dry::CLI::Command
        include SemanticLogger::Loggable

        desc "Recursively iterates through all of the asciidoc files inside --asciidoc_source_folder , runs 
        asciidoc-reducer on them, and saves the output into --antora_intermediate_folder. Files with the middle suffix 
        .src .prebuild and .pdf are not reduced, although they can be included in the other files using the asciidoc 
        include[] directive." 

        option :asciidoc_source_folder, default: :emptyoption, 
          desc: "The folder containing all of the asciidoc files to be reduced."

        option :antora_intermediate_folder, default: :emptyoption, 
          desc: "The location of the intermediate folder into which the reduced asciidoc files should be written."

        option :create_intermediate_folder, default: false, type: :boolean, 
          desc: "If --antora_intermediate_folder does not already exist, create it."

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
            asciidoc_source_folder = WMULPurpleMercury::CLI::Validators.validate_source_folder(asciidoc_source_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --asciidoc_source_folder #{e.message}")
            return
          end
          create_intermediate_folder = options.fetch(:create_intermediate_folder)
          antora_intermediate_folder = options.fetch(:antora_intermediate_folder)
          begin
            antora_intermediate_folder = WMULPurpleMercury::CLI::Validators.validate_build_folder(antora_intermediate_folder, create_intermediate_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --antora_intermediate_folder #{e.message}")
            return
          end
          WMULPurpleMercury::Antora.build_asciidoc_source_for_antora(asciidoc_source_folder, antora_intermediate_folder)
        end
      end


      class CopyAntoraStaticFolder < Dry::CLI::Command
        include SemanticLogger::Loggable

        desc "Copies all of the files from the Antora static folder into the Antora build folder." 

        option :antora_static_folder, default: :emptyoption, 
          desc: "The folder containing all of the Antora static files."

        option :antora_build_folder, default: :emptyoption, 
          desc: "The location of the antora /antora/ folder."

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
          antora_static_folder = options.fetch(:antora_static_folder)
          begin
            antora_static_folder = WMULPurpleMercury::CLI::Validators.validate_source_folder(antora_static_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --antora_static_folder #{e.message}")
            return
          end
          create_build_folder = options.fetch(:create_build_folder)
          antora_build_folder = options.fetch(:antora_build_folder)
          begin
            antora_build_folder = WMULPurpleMercury::CLI::Validators.validate_build_folder(antora_build_folder, create_build_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --antora_build_folder #{e.message}")
            return
          end
          WMULPurpleMercury::Antora.copy_antora_static_folder(antora_static_folder, antora_build_folder)
        end
      end


      # PDF Book

      class BuildAsciidocSourceForPDF < Dry::CLI::Command
        include SemanticLogger::Loggable

        desc "Recursively iterates through all of the asciidoc files inside --asciidoc_source_folder , runs 
        asciidoc-reducer on them, and saves the output into --pdf_intermediate. Files with the middle suffix .src 
        .prebuild and .antora are not reduced, although they can be included in the other files using the asciidoc 
        include[] directive." 

        option :asciidoc_source_folder, default: :emptyoption, 
          desc: "The folder containing all of the asciidoc files to be reduced."

        option :pdf_intermediate_folder, default: :emptyoption, 
          desc: "The location of the intermediate folder into which the reduced asciidoc files should be written."

        option :create_intermediate_folder, default: false, type: :boolean, 
          desc: "If --antora_intermediate_folder does not already exist, create it."

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
            asciidoc_source_folder = WMULPurpleMercury::CLI::Validators.validate_source_folder(asciidoc_source_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --asciidoc_source_folder #{e.message}")
            return
          end
          create_intermediate_folder = options.fetch(:create_intermediate_folder)
          pdf_intermediate_folder = options.fetch(:pdf_intermediate_folder)
          begin
            pdf_intermediate_folder = WMULPurpleMercury::CLI::Validators.validate_build_folder(pdf_intermediate_folder, create_intermediate_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --pdf_intermediate_folder #{e.message}")
            return
          end
          WMULPurpleMercury::PDFBook.build_asciidoc_source_for_pdf(asciidoc_source_folder, pdf_intermediate_folder)
        end
      end


      class CopyPDFStaticFolder < Dry::CLI::Command
        include SemanticLogger::Loggable

        desc "Copies all of the files from the pdf static folder into the pdf build folder." 

        option :pdf_static_folder, default: :emptyoption, 
          desc: "The folder containing all of the pdf static files."

        option :pdf_build_folder, default: :emptyoption, 
          desc: "The location of the pdf build folder."

        option :create_build_folder, default: false, type: :boolean, 
          desc: "If --pdf_build_folder does not already exist, create it."

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
          pdf_static_folder = options.fetch(:pdf_static_folder)
          begin
            pdf_static_folder = WMULPurpleMercury::CLI::Validators.validate_source_folder(pdf_static_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --pdf_static_folder #{e.message}")
            return
          end
          create_build_folder = options.fetch(:create_build_folder)
          pdf_build_folder = options.fetch(:pdf_build_folder)
          begin
            pdf_build_folder = WMULPurpleMercury::CLI::Validators.validate_build_folder(pdf_build_folder, create_build_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --pdf_build_folder #{e.message}")
            return
          end
          pdf_static_folder = pdf_static_folder.realpath()
          pdf_build_folder = pdf_build_folder.realpath()
          WMULPurpleMercury::PDFBook.copy_pdf_static_folder(pdf_static_folder, pdf_build_folder)
        end
      end


      class BuildPreBuildAsciidocsToPDF < Dry::CLI::Command
        include SemanticLogger::Loggable

        desc "Recursively iterates through all of the asciidoc files inside --asciidoc_source_folder , runs 
        asciidoctor-pdf on them, and saves the output into --pdf_build_folder. Only .adoc files with the middle suffix 
        .prebuild are converted"

        option :asciidoc_source_folder, default: :emptyoption, 
          desc: "The folder containing all of the asciidoc files to be reduced."

        option :pdf_build_folder, default: :emptyoption, 
          desc: "The location of the build folder into which the rendered pdf files should be written."

        option :create_build_folder, default: false, type: :boolean, 
          desc: "If --pdf_build_folder does not already exist, create it."

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
            asciidoc_source_folder = WMULPurpleMercury::CLI::Validators.validate_source_folder(asciidoc_source_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --asciidoc_source_folder #{e.message}")
            return
          end
          create_build_folder = options.fetch(:create_build_folder)
          pdf_build_folder = options.fetch(:pdf_build_folder)
          begin
            pdf_build_folder = WMULPurpleMercury::CLI::Validators.validate_build_folder(pdf_build_folder, create_build_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --pdf_build_folder #{e.message}")
            return
          end
          asciidoc_source_folder = asciidoc_source_folder.realpath()
          pdf_build_folder = pdf_build_folder.realpath()
          WMULPurpleMercury::PDFBook.build_prebuild_asciidocs_to_pdf(asciidoc_source_folder, pdf_build_folder)
        end
      end


      class BuildPDFs < Dry::CLI::Command
        include SemanticLogger::Loggable

        desc "Non-recursively iterates through the asciidoc files in the root of --pdf_build_folder , runs 
        asciidoctor-pdf on them, and saves the output into --renders_folder. Only .adoc files in the root of 
        --pdf_build_folder are converted."

        option :pdf_build_folder, default: :emptyoption, 
          desc: "The root folder containing the asciidoc files to be converted."

        option :renders_folder, default: :emptyoption, 
          desc: "The location of the renders folder into which the rendered pdf files should be written."

        option :create_renders_folder, default: false, type: :boolean, 
          desc: "If --renders_folder does not already exist, create it."

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
          pdf_build_folder = options.fetch(:pdf_build_folder)
          begin
            pdf_build_folder = WMULPurpleMercury::CLI::Validators.validate_source_folder(pdf_build_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --pdf_build_folder #{e.message}")
            return
          end
          create_renders_folder = options.fetch(:create_renders_folder)
          renders_folder = options.fetch(:renders_folder)
          begin
            renders_folder = WMULPurpleMercury::CLI::Validators.validate_build_folder(renders_folder, create_renders_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --renders_folder #{e.message}")
            return
          end
          pdf_build_folder = pdf_build_folder.realpath()
          renders_folder = renders_folder.realpath()
          WMULPurpleMercury::PDFBook.build_pdfs(pdf_build_folder, renders_folder)
        end
      end


      # ePub

      class BuildAsciidocSourceForEPub < Dry::CLI::Command
        include SemanticLogger::Loggable

        desc "Recursively iterates through all of the asciidoc files inside --asciidoc_source_folder , runs 
        asciidoc-reducer on them, and saves the output into --epub_intermediate_folder. Files with the middle suffix 
        .src .prebuild, and .antora and .pdf are not reduced, although they can be included in the other files using 
        the asciidoc include[] directive." 

        option :asciidoc_source_folder, default: :emptyoption, 
          desc: "The folder containing all of the asciidoc files to be reduced."

        option :epub_intermediate_folder, default: :emptyoption, 
          desc: "The location of the intermediate folder into which the reduced asciidoc files should be written."

        option :create_intermediate_folder, default: false, type: :boolean, 
          desc: "If --epub_intermediate_folder does not already exist, create it."

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
            asciidoc_source_folder = WMULPurpleMercury::CLI::Validators.validate_source_folder(asciidoc_source_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --asciidoc_source_folder #{e.message}")
            return
          end
          create_intermediate_folder = options.fetch(:create_intermediate_folder)
          epub_intermediate_folder = options.fetch(:epub_intermediate_folder)
          begin
            epub_intermediate_folder = WMULPurpleMercury::CLI::Validators.validate_build_folder(epub_intermediate_folder, create_intermediate_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --epub_intermediate_folder #{e.message}")
            return
          end
          WMULPurpleMercury::EPub.build_asciidoc_source_for_epub(asciidoc_source_folder, epub_intermediate_folder)
        end
      end


      class CopyEPubStaticFolder < Dry::CLI::Command
        include SemanticLogger::Loggable

        desc "Copies all of the files from the ePub static folder into the ePub build folder." 

        option :epub_static_folder, default: :emptyoption, 
          desc: "The folder containing all of the epub static files."

        option :epub_build_folder, default: :emptyoption, 
          desc: "The location of the epub build folder."

        option :create_build_folder, default: false, type: :boolean, 
          desc: "If --pdf_build_folder does not already exist, create it."

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
          epub_static_folder = options.fetch(:epub_static_folder)
          begin
            epub_static_folder = WMULPurpleMercury::CLI::Validators.validate_source_folder(epub_static_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --epub_static_folder #{e.message}")
            return
          end
          create_build_folder = options.fetch(:create_build_folder)
          epub_build_folder = options.fetch(:epub_build_folder)
          begin
            epub_build_folder = WMULPurpleMercury::CLI::Validators.validate_build_folder(epub_build_folder, create_build_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --epub_build_folder #{e.message}")
            return
          end
          epub_static_folder = epub_static_folder.realpath()
          epub_build_folder = epub_build_folder.realpath()
          WMULPurpleMercury::EPub.copy_epub_static_folder(epub_static_folder, epub_build_folder)
        end
      end

      class BuildEPubs < Dry::CLI::Command
        include SemanticLogger::Loggable

        desc "Non-recursively iterates through the asciidoc files in the root of --epub_build_folder , runs 
        asciidoctor-epub3 on them, and saves the output into --renders_folder. Only .adoc files in the root of 
        --epub_build_folder are converted."

        option :epub_build_folder, default: :emptyoption, 
          desc: "The root folder containing the asciidoc files to be converted."

        option :renders_folder, default: :emptyoption, 
          desc: "The location of the renders folder into which the rendered epub files should be written."

        option :create_renders_folder, default: false, type: :boolean, 
          desc: "If --renders_folder does not already exist, create it."

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
          epub_build_folder = options.fetch(:epub_build_folder)
          begin
            epub_build_folder = WMULPurpleMercury::CLI::Validators.validate_source_folder(epub_build_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --epub_build_folder #{e.message}")
            return
          end
          create_renders_folder = options.fetch(:create_renders_folder)
          renders_folder = options.fetch(:renders_folder)
          begin
            renders_folder = WMULPurpleMercury::CLI::Validators.validate_build_folder(renders_folder, create_renders_folder)
          rescue ArgumentError => e
            logger.fatal("Argument Bad: --renders_folder #{e.message}")
            return
          end
          epub_build_folder = epub_build_folder.realpath()
          renders_folder = renders_folder.realpath()
          WMULPurpleMercury::EPub.build_epubs(epub_build_folder, renders_folder)
        end
      end


    end


    module Validators
      include SemanticLogger::Loggable 
      def self.validate_source_folder(source_folder)
        logger.info("validate_source_folder:: #{source_folder}")
        if source_folder == :emptyoption
          raise ArgumentError.new("is a required argument.")
        end
        source_folder_path = Pathname.new(source_folder)
        unless source_folder_path.exist?()
          raise ArgumentError.new("#{source_folder} does not exist.")
        end
        unless source_folder_path.directory?()
          raise ArgumentError.new("#{source_folder} is not a folder.")
        end
        unless source_folder_path.readable?()
          raise ArgumentError.new("#{source_folder} is not readable.")
        end
        return source_folder_path
      end


      def self.validate_build_folder(build_folder, create_build_folder)
        logger.info("validate_build_folder:: #{build_folder}")
        if build_folder == :emptyoption
          raise ArgumentError.new("is a required argument.")
        end
        build_folder_path = Pathname.new(build_folder)
        unless build_folder_path.exist?()
          if create_build_folder
            logger.info("validate_build_folder:: Creating build folder.")
            build_folder_path.mkpath(mode: 0644)
          else
            raise ArgumentError.new("#{build_folder} does not exist. It needs to be created or the 
                                    --create_build_folder flag needs to be set.")            
          end
        end
        unless build_folder_path.directory?()
          raise ArgumentError.new("#{build_folder} is not a folder.")
        end
        unless build_folder_path.writable?()
          raise ArgumentError.new("#{build_folder} is not writable.")
        end
        return build_folder_path
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
        dir_name = File.dirname(log_name)
        unless File.writable?(dir_name)
          raise ArgumentError.new("#{log_name} is not writable.")
        end
        if File.exist?(log_name)
          unless File.writable?(log_name)
            raise ArgumentError.new("#{log_name} is not writable.")
          end
        end
      end


      def self.validate_license(license)
        if license.casecmp?("nd")
          return :nd
        elsif license.casecmp?("sa")
          return :sa
        else
          raise ArgumentError.new(" is not a valid value. Expected: 'nd' or 'sa'. Received: #{license}")
        end
      end


      def self.validate_color(color)
        if color.casecmp?("color")
          return :color
        elsif color.casecmp?("grayscale")
          return :grayscale
        else
          raise ArgumentError.new(" is not a valid value. Expected: 'color' or 'grayscale'. Received: #{color}")
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


WMULPurpleMercury::CLI::Commands.register "create_symlinks_for_build", WMULPurpleMercury::CLI::Commands::CreateSymlinksForBuild
WMULPurpleMercury::CLI::Commands.register "create_symlinks_for_common_items", WMULPurpleMercury::CLI::Commands::CreateSymlinksForCommonItems
WMULPurpleMercury::CLI::Commands.register "clean_build_folder", WMULPurpleMercury::CLI::Commands::CleanBuildFolder

WMULPurpleMercury::CLI::Commands.register "build_asciidoc_source_for_antora", WMULPurpleMercury::CLI::Commands::BuildAsciidocSourceForAntora
WMULPurpleMercury::CLI::Commands.register "copy_antora_static_folder", WMULPurpleMercury::CLI::Commands::CopyAntoraStaticFolder

WMULPurpleMercury::CLI::Commands.register "build_asciidoc_source_for_pdf", WMULPurpleMercury::CLI::Commands::BuildAsciidocSourceForPDF
WMULPurpleMercury::CLI::Commands.register "copy_pdf_static_folder", WMULPurpleMercury::CLI::Commands::CopyPDFStaticFolder
WMULPurpleMercury::CLI::Commands.register "build_prebuild_asciidocs_to_pdf", WMULPurpleMercury::CLI::Commands::BuildPreBuildAsciidocsToPDF
WMULPurpleMercury::CLI::Commands.register "build_pdfs", WMULPurpleMercury::CLI::Commands::BuildPDFs

WMULPurpleMercury::CLI::Commands.register "build_asciidoc_source_for_epub", WMULPurpleMercury::CLI::Commands::BuildAsciidocSourceForEPub
WMULPurpleMercury::CLI::Commands.register "copy_epub_static_folder", WMULPurpleMercury::CLI::Commands::CopyEPubStaticFolder
WMULPurpleMercury::CLI::Commands.register "build_epubs", WMULPurpleMercury::CLI::Commands::BuildEPubs


WMULPurpleMercury::CLI::Commands.register "copy_rendered_items", WMULPurpleMercury::CLI::Commands::CopyRenderedItems

WMULPurpleMercury::CLI::Commands.register "version",  WMULPurpleMercury::CLI::Commands::Version
WMULPurpleMercury::CLI::Commands.register "v",  WMULPurpleMercury::CLI::Commands::Version

Dry::CLI.new(WMULPurpleMercury::CLI::Commands).call
