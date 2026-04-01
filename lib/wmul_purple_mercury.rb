require 'asciidoctor/reducer/api'
require "semantic_logger"

module WMULPurpleMercury
    module Build
        include SemanticLogger::Loggable

        def self.build_asciidoc_source_for_antora(asciidoc_source_folder, antora_build_folder)
            logger.info("With:: AsciiDoc Source Folder: #{asciidoc_source_folder} , Antora Build Folder: #{antora_build_folder}")
            excluded_suffixes = [".src", ".prebuild", ".pdf"]
            WMULPurpleMercury::Build.build_asciidoc_source(asciidoc_source_folder, antora_build_folder, excluded_suffixes, "antora", false)
        end


        def self.build_asciidoc_source(asciidoc_source_folder, build_folder, excluded_suffixes, backend, book)
            logger.info("With:: AsciiDoc Source Folder: #{asciidoc_source_folder} , Build Folder: #{build_folder} , Excluded Suffixes: #{excluded_suffixes} , Backend: #{backend} , Book: #{book}")
            asciidoc_source_files = WMULPurpleMercury::FileNameManager.get_sorted_file_names(asciidoc_source_folder, build_folder)
            asciidoc_source_files.each do |file_pair|
                unless WMULPurpleMercury::FileNameManager::file_name_contains_any_suffix?(file_pair.source_file_name, excluded_suffixes)
                    destination_file_name = WMULPurpleMercury::FileNameManager.strip_middle_suffix_from_filename(file_pair.destination_file_name, ".#{backend}")
                    reduce_asciidoc(file_pair.source_file_name, destination_file_name, backend, book)
                end
            end
        end


        def self.reduce_asciidoc(source_file, destination_file, backend, book)
            logger.info("With:: Source File: #{source_file} , Destination File: #{destination_file} , Backend: #{backend} , Book: #{book}")
            if book
                Asciidoctor::Reducer.reduce_file source_file, safe: :unsafe, to: destination_file, doctype: :book, attributes: "#{backend}=true"
            else
                Asciidoctor::Reducer.reduce_file source_file, safe: :unsafe, to: destination_file, attributes: "#{backend}=true"
            end
        end
    end


    module FileNameManager
        include SemanticLogger::Loggable

        def self.get_sorted_file_names(source_root, output_root, output_suffix = nil)
            logger.info("With:: Source Root: #{source_root} , Output Root: #{output_root} , Output Suffix: #{output_suffix}")
            file_paths = []
            Dir.glob("**/*.adoc", base: source_root).each do |file_name|
                source_file_name = File.join(source_root, file_name)
                destination_file_name = File.join(output_root, file_name)
                if output_suffix
                    destination_file_name = WMULPurpleMercury::FileNameManager.replace_suffix(destination_file_name, output_suffix)
                end
                logger.info("File Pair:: Source File Name: #{source_file_name} , Destination File Name: #{destination_file_name}")
                fp = FilePair.new(source_file_name, destination_file_name)
                file_paths << fp
            end
            return file_paths
        end

        def self.replace_suffix(original_file_name, new_suffix)
            lastIndexOfDot = original_file_name.rindex(".")
            if lastIndexOfDot
                basename = original_file_name[0, lastIndexOfDot]
                return basename + new_suffix
            else
                return original_file_name
            end
        end

        def self.file_name_contains_any_suffix?(file_name, suffixes)
            return suffixes.any? { |suffix| WMULPurpleMercury::FileNameManager.file_name_contains_suffix?(file_name, suffix) }
        end

        def self.file_name_contains_suffix?(file_name, suffix)
            logger.info("With:: #{file_name} , Suffix: #{suffix}")
            basename = File.basename(file_name)
            return basename.include?(suffix)
        end

        def self.strip_middle_suffix_from_filename(destination_file_name, middle_suffix)
            logger.info("With Destination File Name: #{destination_file_name} , Middle Suffix: #{middle_suffix}")
            basename = File.basename(destination_file_name)
            lastIndexOfMiddleSuffix = basename.rindex(middle_suffix)
            if lastIndexOfMiddleSuffix
                before_suffix = basename[0, lastIndexOfMiddleSuffix]
                after_suffix = basename[lastIndexOfMiddleSuffix..]
                after_suffix = after_suffix.gsub(middle_suffix, "")
                basename = before_suffix + after_suffix
            end
            parent = File.dirname(destination_file_name)
            return File.join(parent, basename)
        end
    end



    class FilePair
        attr_reader :source_file_name, :destination_file_name

        def initialize(source_file_name, destination_file_name)
            @source_file_name = source_file_name
            @destination_file_name = destination_file_name
        end

        def to_s()
            return "FilePair: Source: #{@source_file_name} , Destination #{@destination_file_name}"
        end
    end
end
