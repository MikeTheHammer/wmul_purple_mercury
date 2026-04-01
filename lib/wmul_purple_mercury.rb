require 'asciidoctor/reducer/api'
require "semantic_logger"

module WMULPurpleMercury
    module Build
        include SemanticLogger::Loggable

        def self.build_asciidoc_source_for_antora(asciidoc_source_folder, antora_pages_folder)
            logger.info("build_asciidoc_source_for_antora:: AsciiDoc Source Folder: #{asciidoc_source_folder} , Antora Pages Folder: #{antora_pages_folder}")
            excluded_suffixes = [".src", ".prebuild", ".pdf"]
            WMULPurpleMercury::Build.build_asciidoc_source(asciidoc_source_folder, antora_pages_folder, excluded_suffixes, "antora", false)
        end




        def self.copy_antora_static_folder(antora_static_folder, antora_build_folder)
            logger.info("copy_antora_static_folder:: Antora Static Folder: #{antora_static_folder} , Antora Build Folder: #{antora_build_folder}")
            antora_static_files = WMULPurpleMercury::FileNameManager.get_sorted_file_names(antora_static_folder, antora_build_folder)
            antora_suffixes = [".adoc", ".yml", ".yaml"]
            WMULPurpleMercury::Build.copy_files(antora_static_files, antora_suffixes)
        end


        def self.build_asciidoc_source(asciidoc_source_folder, build_folder, excluded_suffixes, backend, book)
            logger.info("build_asciidoc_source:: AsciiDoc Source Folder: #{asciidoc_source_folder} , Build Folder: #{build_folder} , Excluded Suffixes: #{excluded_suffixes} , Backend: #{backend} , Book: #{book}")
            asciidoc_source_files = WMULPurpleMercury::FileNameManager.get_sorted_file_names(asciidoc_source_folder, build_folder)
            asciidoc_source_files.each do |file_pair|
                unless WMULPurpleMercury::FileNameManager::file_name_contains_any_suffix?(file_pair.source_file_name, excluded_suffixes)
                    destination_file_name = WMULPurpleMercury::FileNameManager.strip_middle_suffix_from_filename(file_pair.destination_file_name, ".#{backend}")
                    reduce_asciidoc(file_pair.source_file_name, destination_file_name, backend, book)
                end
            end
        end


        def self.reduce_asciidoc(source_file, destination_file, backend, book)
            logger.info("reduce_asciidoc:: Source File: #{source_file} , Destination File: #{destination_file} , Backend: #{backend} , Book: #{book}")
            if book
                Asciidoctor::Reducer.reduce_file source_file, safe: :unsafe, to: destination_file, doctype: :book, attributes: "#{backend}=true"
            else
                Asciidoctor::Reducer.reduce_file source_file, safe: :unsafe, to: destination_file, attributes: "#{backend}=true"
            end
        end

        def self.copy_files(file_list, file_suffixes)
            logger.info("copy_files:: File List: #{file_list} , File Suffixes: #{file_suffixes}")
            file_list.each do |file_pair|
                source_file = file_pair.source_file_name
                destination_file = file_pair.destination_file_name
                suffix = source_file.extname()
                if file_suffixes.include?(suffix)
                    destination_parent = destination_file.dirname()
                    destination_parent.mkpath(mode: 0644)
                    FileUtils.copy_file(source_file, destination_file)
                end
            end
        end
    end


    module FileNameManager
        include SemanticLogger::Loggable

        def self.get_sorted_file_names(source_root, output_root, output_suffix = nil)
            logger.info("get_sorted_file_names:: Source Root: #{source_root} , Output Root: #{output_root} , Output Suffix: #{output_suffix}")
            file_paths = []
            Dir.glob("**/*.adoc", base: source_root).each do |file_name|
                source_file_name = source_root + file_name
                destination_file_name = output_root + file_name
                if output_suffix
                    destination_file_name = WMULPurpleMercury::FileNameManager.replace_suffix(destination_file_name.to_s(), output_suffix)
                end
                logger.info("get_sorted_file_names:: File Pair:: Source File Name: #{source_file_name} , Destination File Name: #{destination_file_name}")
                fp = FilePair.new(source_file_name, destination_file_name)
                file_paths << fp
            end
            return file_paths
        end

        def self.replace_suffix(original_file_name, new_suffix)
            original_file_name_string = original_file_name.to_s()
            lastIndexOfDot = original_file_name_string.rindex(".")
            if lastIndexOfDot
                basename = original_file_name_string[0, lastIndexOfDot]
                return Pathname.new(basename + new_suffix)
            else
                return original_file_name
            end
        end

        def self.file_name_contains_any_suffix?(file_name, suffixes)
            return suffixes.any? { |suffix| WMULPurpleMercury::FileNameManager.file_name_contains_suffix?(file_name, suffix) }
        end

        def self.file_name_contains_suffix?(file_name, suffix)
            logger.info("file_name_contains_suffix?:: #{file_name} , Suffix: #{suffix}")
            basename = file_name.basename().to_s()
            return basename.include?(suffix)
        end

        def self.strip_middle_suffix_from_filename(destination_file_name, middle_suffix)
            logger.info("strip_middle_suffix_from_filename:: Destination File Name: #{destination_file_name} , Middle Suffix: #{middle_suffix}")
            basename = destination_file_name.basename().to_s()
            lastIndexOfMiddleSuffix = basename.rindex(middle_suffix)
            if lastIndexOfMiddleSuffix
                before_suffix = basename[0, lastIndexOfMiddleSuffix]
                after_suffix = basename[lastIndexOfMiddleSuffix..]
                after_suffix = after_suffix.gsub(middle_suffix, "")
                basename = before_suffix + after_suffix
            end
            parent = destination_file_name.dirname()
            return parent + basename
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
