require "minitest/autorun"
require "wmul_purple_mercury"

class TestFilenameContainsAnySuffix < Minitest::Test
    def test_one_suffix_true()
        test = Pathname.new("/foo/bar/test.adoc")
        result = WMULPurpleMercury::FileNameManager.file_name_contains_any_suffix?(test, [".adoc", ".pdf"])
        assert_equal true, result
    end

    def test_multiple_suffix_true()
        test = Pathname.new("/foo/bar/test.foo.adoc")
        result = WMULPurpleMercury::FileNameManager.file_name_contains_any_suffix?(test, [".adoc", ".pdf"])
        assert_equal true, result
    end

    def test_not_the_final_suffix_true()
        test = Pathname.new("/foo/bar/test.adoc.foo.bar")
        result = WMULPurpleMercury::FileNameManager.file_name_contains_any_suffix?(test, [".adoc", ".pdf"])
        assert_equal true, result
    end

    def test_one_suffix_false()
        test = Pathname.new("/foo/bar/test.docx")
        result = WMULPurpleMercury::FileNameManager.file_name_contains_any_suffix?(test, [".adoc", ".pdf"])
        assert_equal false, result
    end

    def test_multiple_suffix_false()
        test = Pathname.new("/foo/bar/test.foo.docx")
        result = WMULPurpleMercury::FileNameManager.file_name_contains_any_suffix?(test, [".adoc", ".pdf"])
        assert_equal false, result
    end
end


class TestFilenameContainsSuffix < Minitest::Test
    def test_one_suffix_true()
        test = Pathname.new("/foo/bar/test.adoc")
        result = WMULPurpleMercury::FileNameManager.file_name_contains_suffix?(test, ".adoc")
        assert_equal true, result
    end

    def test_multiple_suffix_true()
        test = Pathname.new("/foo/bar/test.foo.adoc")
        result = WMULPurpleMercury::FileNameManager.file_name_contains_suffix?(test, ".adoc")
        assert_equal true, result
    end

    def test_not_the_final_suffix_true()
        test = Pathname.new("/foo/bar/test.adoc.foo.bar")
        result = WMULPurpleMercury::FileNameManager.file_name_contains_suffix?(test, ".adoc")
        assert_equal true, result
    end

    def test_one_suffix_false()
        test = Pathname.new("/foo/bar/test.docx")
        result = WMULPurpleMercury::FileNameManager.file_name_contains_suffix?(test, ".adoc")
        assert_equal false, result
    end

    def test_multiple_suffix_false()
        test = Pathname.new("/foo/bar/test.foo.docx")
        result = WMULPurpleMercury::FileNameManager.file_name_contains_suffix?(test, ".adoc")
        assert_equal false, result
    end
end


class TestReplaceSuffix < Minitest::Test

    def test_no_suffix()
        test = Pathname.new("/foo/bar/testadoc")
        expected = Pathname.new("/foo/bar/testadoc")
        result = WMULPurpleMercury::FileNameManager.replace_suffix(test, ".docx")
        assert_equal expected, result
    end

    def test_one_suffix()
        test = Pathname.new("/foo/bar/test.adoc")
        expected = Pathname.new("/foo/bar/test.docx")
        result = WMULPurpleMercury::FileNameManager.replace_suffix(test, ".docx")
        assert_equal expected, result
    end

    def test_two_suffixes()
        test = Pathname.new("/foo/bar/test.foo.adoc")
        expected = Pathname.new("/foo/bar/test.foo.docx")
        result = WMULPurpleMercury::FileNameManager.replace_suffix(test, ".docx")
        assert_equal expected, result
    end

    def test_repeated_suffix()
        test = Pathname.new("/foo/bar/test.adoc.adoc")
        expected = Pathname.new("/foo/bar/test.adoc.docx")
        result = WMULPurpleMercury::FileNameManager.replace_suffix(test, ".docx")
        assert_equal expected, result
    end

    def test_repeated_separated_suffix()
        test = Pathname.new("/foo/bar/test.adoc.foo.adoc")
        expected = Pathname.new("/foo/bar/test.adoc.foo.docx")
        result = WMULPurpleMercury::FileNameManager.replace_suffix(test, ".docx")
        assert_equal expected, result
    end
end


class TestStripMiddleSuffixFromFileName < Minitest::Test
    def test_two_suffixes()
        test = Pathname.new("/foo/bar/test.foo.adoc")
        expected = Pathname.new("/foo/bar/test.adoc")
        result = WMULPurpleMercury::FileNameManager.strip_middle_suffix_from_filename(test, ".foo")
        assert_equal expected, result
    end

    def test_three_suffixes()
        test = Pathname.new("/foo/bar/test.adoc.foo.bar")
        expected = Pathname.new("/foo/bar/test.adoc.bar")
        result = WMULPurpleMercury::FileNameManager.strip_middle_suffix_from_filename(test, ".foo")
        assert_equal expected, result
    end

    def test_suffix_not_present()
        test = Pathname.new("/foo/bar/test.adoc")
        expected = Pathname.new("/foo/bar/test.adoc")
        result = WMULPurpleMercury::FileNameManager.strip_middle_suffix_from_filename(test, ".foo")
        assert_equal expected, result
    end

    def test_suffix_repeated()
        test = Pathname.new("/foo/bar/test.foo.docx.foo.bar")
        expected = Pathname.new("/foo/bar/test.foo.docx.bar")
        result = WMULPurpleMercury::FileNameManager.strip_middle_suffix_from_filename(test, ".foo")
        assert_equal expected, result
    end
end
