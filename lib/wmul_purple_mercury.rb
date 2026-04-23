require 'asciidoctor-pdf'
require 'asciidoctor-epub3'
require 'asciidoctor/reducer/api'
require 'fileutils'
require "semantic_logger"

module WMULPurpleMercury
    ALL_SUFFIXES = [".src", ".prebuild", ".antora", ".pdf", ".epub", ".standalone"]
    module Setup
        include SemanticLogger::Loggable

        def self.create_symlinks_for_build(license, color, build_root, images_root, attachments_root)
            build_root = build_root.expand_path()
            images_root = images_root.expand_path()
            attachments_root = attachments_root.expand_path()

            images_color_license_path = images_root + color.name + license.name
            images_path = build_root + "images"
            WMULPurpleMercury::Setup.create_symlink_between_folders(images_color_license_path, images_path)

            attachments_license_path = attachments_root + license.name
            attachments_path = build_root + "attachments"
            WMULPurpleMercury::Setup.create_symlink_between_folders(attachments_license_path, attachments_path)
        end


        def self.create_symlinks_for_common_items(images_root, attachments_root)
            images_root = images_root.expand_path()
            attachments_root = attachments_root.expand_path()

            WMULPurpleMercury::Setup.create_symlinks_for_common_images(images_root)
            WMULPurpleMercury::Setup.create_common_license_symlinks(attachments_root)
        end


        def self.create_symlinks_for_common_images(images_root)
            color_path = images_root + "color"
            common_color_path = images_root + "common_color"
            WMULPurpleMercury::Setup.create_common_license_common_color_symlinks(color_path, common_color_path)

            grayscale_path = images_root + "grayscale"
            WMULPurpleMercury::Setup.create_common_license_common_color_symlinks(grayscale_path, common_color_path)

            WMULPurpleMercury::Setup.create_common_license_symlinks(common_color_path)
        end


        def self.create_common_license_symlinks(root_path)
            nd_path = root_path + "nd"
            sa_path = root_path + "sa"
            common_license_path = root_path + "common_license"

            nd_common_license_path = nd_path + "common_license"
            WMULPurpleMercury::Setup.create_symlink_between_folders(common_license_path, nd_common_license_path)

            sa_common_license_path = sa_path + "common_license"
            WMULPurpleMercury::Setup.create_symlink_between_folders(common_license_path, sa_common_license_path)
        end
        

        def self.create_common_license_common_color_symlinks(color_path, common_color_path)
            common_license_path = color_path + "common_license"
            color_nd_path = color_path + "nd"
            common_color_nd_path = common_color_path + "nd"
            color_sa_path = color_path + "sa"
            common_color_sa_path = common_color_path + "sa"

            nd_common_license_path = color_nd_path + "common_license"
            WMULPurpleMercury::Setup.create_symlink_between_folders(common_license_path, nd_common_license_path)
            nd_common_color_path = color_nd_path + "common_color"
            WMULPurpleMercury::Setup.create_symlink_between_folders(common_color_nd_path, nd_common_color_path)

            sa_common_license_path = color_sa_path + "common_license"
            WMULPurpleMercury::Setup.create_symlink_between_folders(common_license_path, sa_common_license_path)
            sa_common_color_path = color_sa_path + "common_color"
            WMULPurpleMercury::Setup.create_symlink_between_folders(common_color_sa_path, sa_common_color_path)
        end


        def self.create_symlink_between_folders(target_path, source_path)
            logger.info("create_symlink_between_folders:: Target Path #{target_path} , Source Path: #{source_path}")
            WMULPurpleMercury::Setup.check_if_path_exists_and_not_symlink(source_path)
            if source_path.symlink?()
                logger.info("#{source_path} already exists, unlinking.")
                source_path.unlink()
            end
            source_path.make_symlink(target_path)
        end


        def self.check_if_path_exists_and_not_symlink(path_under_test)
            if (path_under_test.exist?()) && (path_under_test.symlink?() == false)
                logger.fatal("The path #{path_under_test} already exists, but it is not a symlink. Exiting...")
                raise ArgumentError("The path #{path_under_test} already exists, but it is not a symlink. Exiting...")
            end
        end


        def self.clean_build_folder(build_folder)
            build_folder.rmtree(secure: true)
            build_folder.mkpath(mode: 0744)
        end


        def self.copy_rendered_items(source_folder, destination_folder)
            logger.info("copy_rendered_items:: Source Folder: #{source_folder} , Destination Folder: #{destination_folder}")
            FileUtils.cp_r(source_folder, destination_folder, remove_destination:  true)
        end
    end



    module Antora
        include SemanticLogger::Loggable

        def self.build_asciidoc_source_for_antora(asciidoc_source_folder, antora_intermediate_folder)
            logger.info("build_asciidoc_source_for_antora:: AsciiDoc Source Folder: #{asciidoc_source_folder} , Antora Intermediate Folder: #{antora_intermediate_folder}")
            excluded_suffixes = Array.new(WMULPurpleMercury::ALL_SUFFIXES)
            excluded_suffixes.delete(".antora")
            WMULPurpleMercury::BuildCommon.build_asciidoc_source(asciidoc_source_folder, antora_intermediate_folder, excluded_suffixes, "antora", false)
        end

        def self.copy_antora_static_folder(antora_static_folder, antora_build_folder)
            logger.info("copy_antora_static_folder:: Antora Static Folder: #{antora_static_folder} , Antora Build Folder: #{antora_build_folder}")
            antora_static_files = WMULPurpleMercury::FileNameManager.get_sorted_file_names(antora_static_folder, antora_build_folder)
            antora_suffixes = [".adoc", ".yml", ".yaml"]
            WMULPurpleMercury::BuildCommon.copy_files_having_suffix(antora_static_files, antora_suffixes)
        end
    end


    module PDFBook
        include SemanticLogger::Loggable

        def self.build_asciidoc_source_for_pdf(asciidoc_source_folder, pdf_intermediate_folder)
            logger.info("build_asciidoc_source_for_pdf:: AsciiDoc Source Folder: #{asciidoc_source_folder} , PDF Intermediate Folder: #{pdf_intermediate_folder}")
            excluded_suffixes = Array.new(WMULPurpleMercury::ALL_SUFFIXES)
            excluded_suffixes.delete(".pdf")
            WMULPurpleMercury::BuildCommon.build_asciidoc_source(asciidoc_source_folder, pdf_intermediate_folder, excluded_suffixes, "pdf", true)
        end


        def self.copy_pdf_static_folder(pdf_static_folder, pdf_build_folder)
            logger.info("copy_pdf_static_folder:: PDF Static Folder: #{pdf_static_folder} , PDF Build Folder: #{pdf_build_folder}")
            pdf_static_files = WMULPurpleMercury::FileNameManager.get_sorted_file_names(pdf_static_folder, pdf_build_folder)
            pdf_suffixes = [".adoc", ".yml", ".yaml", ".ttf"]
            WMULPurpleMercury::BuildCommon.copy_files_having_suffix(pdf_static_files, pdf_suffixes)
        end


        def self.build_prebuild_asciidocs_to_pdf(asciidoc_source_folder, pdf_build_folder)
            pdf_prebuild_files = WMULPurpleMercury::FileNameManager.get_sorted_file_names(asciidoc_source_folder, pdf_build_folder, input_suffix: ".adoc")
            required_suffixes = [".prebuild", ".adoc"]

            pdf_prebuild_files.each do |file_pair|
                if WMULPurpleMercury::FileNameManager.file_name_contains_all_suffixes?(file_pair.source_file_name, required_suffixes)
                    destination_file_name = WMULPurpleMercury::FileNameManager.strip_middle_suffix_from_filename(file_pair.destination_file_name, ".prebuild")
                    destination_file_name = destination_file_name.sub_ext(".pdf")
                    WMULPurpleMercury::PDFBook.convert_asciidoc_file_to_pdf(file_pair.source_file_name, destination_file_name)
                end
            end

        end


        def self.build_pdfs(pdf_build_folder, renders_folder)
            Dir.glob("*.adoc", base: pdf_build_folder).each do |file_name|
                source_file_name = pdf_build_folder + file_name
                destination_file_name = renders_folder + file_name
                destination_file_name = destination_file_name.sub_ext(".pdf")
                WMULPurpleMercury::PDFBook.convert_asciidoc_file_to_pdf(source_file_name, destination_file_name)
            end
        end


        def self.convert_asciidoc_file_to_pdf(input_file, output_file)
            logger.info("convert_asciidoc_file_to_pdf:: Input File: #{input_file} , Output File: #{output_file}")
            basedir = input_file.parent()
            Dir.chdir(basedir)
            Asciidoctor.convert_file input_file.to_s(), safe: :unsafe, backend: 'pdf', doctype: :book, to_file: output_file.to_s(), attributes: "pdf=true", mkdirs: true, base_dir: basedir.to_s()
        end

    end



    module EPub
        include SemanticLogger::Loggable

        def self.build_asciidoc_source_for_epub(asciidoc_source_folder, epub_intermediate_folder)
            logger.info("build_asciidoc_source_for_epub:: AsciiDoc Source Folder: #{asciidoc_source_folder} , ePub Intermediate Folder: #{epub_intermediate_folder}")
            excluded_suffixes = Array.new(WMULPurpleMercury::ALL_SUFFIXES)
            excluded_suffixes.delete(".epub")
            WMULPurpleMercury::BuildCommon.build_asciidoc_source(asciidoc_source_folder, epub_intermediate_folder, excluded_suffixes, "epub", true)
        end


        def self.copy_epub_static_folder(epub_static_folder, epub_build_folder)
            logger.info("copy_epub_static_folder:: ePub Static Folder: #{epub_static_folder} , ePub Build Folder: #{epub_build_folder}")
            epub_static_files = WMULPurpleMercury::FileNameManager.get_sorted_file_names(epub_static_folder, epub_build_folder)
            epub_suffixes = [".adoc", ".yml", ".yaml", ".ttf"]
            WMULPurpleMercury::BuildCommon.copy_files_having_suffix(epub_static_files, epub_suffixes)
        end


        def self.build_epubs(epub_build_folder, renders_folder)
            Dir.glob("*.adoc", base: epub_build_folder).each do |file_name|
                source_file_name = epub_build_folder + file_name
                destination_file_name = renders_folder + file_name
                destination_file_name = destination_file_name.sub_ext(".epub")
                WMULPurpleMercury::EPub.convert_asciidoc_file_to_epub(source_file_name, destination_file_name)
            end
        end


        def self.convert_asciidoc_file_to_epub(input_file, output_file)
            logger.info("convert_asciidoc_file_to_epub:: Input File: #{input_file} , Output File: #{output_file}")
            basedir = input_file.parent()
            Dir.chdir(basedir)
            Asciidoctor.convert_file input_file.to_s(), safe: :unsafe, backend: 'epub3', doctype: :book, to_file: output_file.to_s(), attributes: "epub=true", mkdirs: true, base_dir: basedir.to_s()
        end


    end



    module BuildCommon
        include SemanticLogger::Loggable

        def self.build_asciidoc_source(asciidoc_source_folder, build_folder, excluded_suffixes, backend, book)
            logger.info("build_asciidoc_source:: AsciiDoc Source Folder: #{asciidoc_source_folder} , Build Folder: #{build_folder} , Excluded Suffixes: #{excluded_suffixes} , Backend: #{backend} , Book: #{book}")
            asciidoc_source_files = WMULPurpleMercury::FileNameManager.get_sorted_file_names(asciidoc_source_folder, build_folder, input_suffix: ".adoc")
            asciidoc_source_files.each do |file_pair|
                unless WMULPurpleMercury::FileNameManager::file_name_contains_any_suffix?(file_pair.source_file_name, excluded_suffixes)
                    destination_file_name = WMULPurpleMercury::FileNameManager.strip_middle_suffix_from_filename(file_pair.destination_file_name, ".#{backend}")
                    WMULPurpleMercury::BuildCommon.reduce_asciidoc(file_pair.source_file_name, destination_file_name, backend, book)
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


        def self.copy_files_having_suffix(file_list, file_suffixes)
            logger.info("copy_files_having_suffix:: File List: #{file_list} , File Suffixes: #{file_suffixes}")
            file_list.each do |file_pair|
                logger.info("Considering:: Source: #{file_pair.source_file_name} , Destination: #{file_pair.destination_file_name}")
                source_file = file_pair.source_file_name
                destination_file = file_pair.destination_file_name
                suffix = source_file.extname()
                if file_suffixes.include?(suffix)
                    logger.info("Copying:: Source: #{file_pair.source_file_name} , Destination: #{file_pair.destination_file_name}")
                    destination_parent = destination_file.dirname()
                    logger.info("Making Parent:: #{destination_parent}")
                    destination_parent.mkpath(mode: 0744)
                    logger.info("Parent Created.")
                    FileUtils.copy_file(source_file, destination_file)
                end
            end
        end
    end



    module FileNameManager
        include SemanticLogger::Loggable

        def self.get_sorted_file_names(source_root, output_root, output_suffix = nil, input_suffix: "")
            logger.info("get_sorted_file_names:: Source Root: #{source_root} , Output Root: #{output_root} , Output Suffix: #{output_suffix}")
            file_paths = []
            Dir.glob("**/*#{input_suffix}", base: source_root).each do |file_name|
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

        def self.file_name_contains_all_suffixes?(file_name, suffixes)
            return suffixes.all? { |suffix| WMULPurpleMercury::FileNameManager.file_name_contains_suffix?(file_name, suffix) }
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
