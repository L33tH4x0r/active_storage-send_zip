# frozen_string_literal: true

require 'test_helper'
require 'pathname'

class ActiveStorageMock
  attr_reader :filename, :download

  def initialize(filename = 'foo.txt')
    @filename = filename
    @download = 'content of file'
  end
end

class ActiveStorage::SendZipTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ActiveStorage::SendZip::VERSION
  end

  def test_it_should_save_one_active_support
    files = [
      ActiveStorageMock.new
    ]

    assert_produce_files files
  end

  def test_it_should_save_two_active_support
    files = [
      ActiveStorageMock.new,
      ActiveStorageMock.new('bar.txt')
    ]

    assert_produce_files files, count: 2
  end

  def test_it_should_save_two_active_support
    files = [
      ActiveStorageMock.new,
      ActiveStorageMock.new
    ]

    assert_produce_files files, count: 2
  end

  def test_it_should_save_files_in_differents_folders
    files = {
      'folder A' => [
        ActiveStorageMock.new,
        ActiveStorageMock.new,
        'folder A1' => [
          ActiveStorageMock.new
        ]
      ],
      'folder B' => [
        ActiveStorageMock.new('bar.txt')
      ]
    }
    assert_produce_nested_files files, folder_count: 3, files_count: 4
  end

  def test_it_should_raise_an_exception
    assert_raises ArgumentError do
      ActiveStorage::SendZipHelper.save_files_on_server 'bad boi'
    end
  end

  def test_it_should_save_files_in_differents_folders_with_root_files
    files = {
      'folder A' => [
        ActiveStorageMock.new,
        ActiveStorageMock.new
      ],
      'folder B' => [
        ActiveStorageMock.new('bar.txt')
      ],
      0 => ActiveStorageMock.new,
      1 => ActiveStorageMock.new('bar.txt')
    }
    assert_produce_nested_files files, folder_count: 4, files_count: 5
  end

  private

  def assert_produce_nested_files(files, folder_count: 1, files_count: 1)
    temp_folder = ActiveStorage::SendZipHelper.save_files_on_server(files)
    puts temp_folder.inspect
    temp_folder_glob = File.join temp_folder, '**', '*'

    glob = Dir.glob(temp_folder_glob)

    files_paths = glob.reject { |e| File.directory? e }
    folders_paths = glob.select { |e| File.directory? e }

    assert_equal folder_count, folders_paths.count
    assert_equal files_count, files_paths.count
    refute_nil ActiveStorage::SendZipHelper.create_temporary_zip_file(temp_folder)
  end

  def assert_produce_files(files, count: 1)
    temp_folder = ActiveStorage::SendZipHelper.save_files_on_server(files)

    temp_folder_glob = File.join temp_folder, '**', '*'
    files_path = Dir.glob(temp_folder_glob).reject { |e| File.directory? e }

    assert_equal count, files_path.count
    refute_nil ActiveStorage::SendZipHelper.create_temporary_zip_file(temp_folder)
  end
end
