# coding: US-ASCII
# frozen_string_literal: true

require_relative '../xref_test_case'

class RDocCodeObjectTest < XrefTestCase

  def setup
    super

    @co = RDoc::CodeObject.new
  end

  def test_initialize
    assert_predicate @co, :document_self, 'document_self'
    assert_predicate @co, :document_children, 'document_children'
    refute_predicate @co, :force_documentation, 'force_documentation'
    refute_predicate @co, :done_documenting, 'done_documenting'
    refute_predicate @co, :received_nodoc, 'received_nodoc'
    assert_equal '', @co.comment, 'comment is empty'
  end

  def test_comment_equals
    @co.comment = ''

    assert_equal '', @co.comment

    @co.comment = 'I am a comment'

    assert_equal 'I am a comment', @co.comment
  end

  def test_comment_equals_comment
    @co.comment = comment ''

    assert_equal '', @co.comment.text

    @co.comment = comment 'I am a comment'

    assert_equal 'I am a comment', @co.comment.text
  end

  def test_comment_equals_empty_string
    @co.comment = 'comment'

    @co.comment = ''

    assert_equal 'comment', @co.comment
  end

  def test_comment_equals_encoding
    refute_equal Encoding::UTF_8, ''.encoding, 'Encoding sanity check'

    input = 'text'
    input = RDoc::Encoding.change_encoding input, Encoding::UTF_8

    @co.comment = input

    assert_equal 'text', @co.comment
    assert_equal Encoding::UTF_8, @co.comment.encoding
  end

  def test_comment_equals_encoding_blank
    refute_equal Encoding::UTF_8, ''.encoding, 'Encoding sanity check'

    input = ''
    input = RDoc::Encoding.change_encoding input, Encoding::UTF_8

    @co.comment = input

    assert_equal '', @co.comment
    assert_equal Encoding::UTF_8, @co.comment.encoding
  end

  def test_display_eh_document_self
    assert_predicate @co, :display?

    @co.document_self = false

    refute_predicate @co, :display?
  end

  def test_display_eh_ignore
    assert_predicate @co, :display?

    @co.ignore

    refute_predicate @co, :display?

    @co.stop_doc

    refute_predicate @co, :display?

    @co.done_documenting = false

    refute_predicate @co, :display?
  end

  def test_display_eh_suppress
    assert_predicate @co, :display?

    @co.suppress

    refute_predicate @co, :display?

    @co.comment = comment('hi')

    refute_predicate @co, :display?

    @co.done_documenting = false

    assert_predicate @co, :display?

    @co.ignore
    @co.done_documenting = false

    refute_predicate @co, :display?
  end

  def test_document_children_equals
    @co.document_children = false

    refute_predicate @co, :document_children

    @store.options.visibility = :nodoc

    @co.store = @store

    assert_predicate @co, :document_children

    @co.document_children = false

    assert_predicate @co, :document_children
  end

  def test_document_self_equals
    @co.document_self = false
    refute_predicate @co, :document_self

    @store.options.visibility = :nodoc

    @co.store = @store

    assert_predicate @co, :document_self

    @co.document_self = false

    assert_predicate @co, :document_self
  end

  def test_documented_eh
    refute_predicate @co, :documented?

    @co.comment = 'hi'

    assert_predicate @co, :documented?

    @co.comment.replace ''

    refute_predicate @co, :documented?

    @co.document_self = nil # notify :nodoc:

    assert_predicate @co, :documented?
  end

  def test_done_documenting
    # once done_documenting is set, other properties refuse to go to "true"
    @co.done_documenting = true

    @co.document_self = true
    refute_predicate @co, :document_self

    @co.document_children = true
    refute_predicate @co, :document_children

    @co.force_documentation = true
    refute_predicate @co, :force_documentation

    @co.start_doc
    refute_predicate @co, :document_self
    refute_predicate @co, :document_children

    # turning done_documenting on
    # resets others to true

    @co.done_documenting = false
    assert_predicate @co, :document_self
    assert_predicate @co, :document_children

    @co.done_documenting = true

    @store.options.visibility = :nodoc

    @co.store = @store

    refute_predicate @co, :done_documenting

    @co.done_documenting = true

    refute_predicate @co, :done_documenting
  end

  def test_file_name
    assert_nil @co.file_name

    @co.record_location @store.add_file 'lib/file.rb'

    assert_equal 'lib/file.rb', @co.file_name
  end

  def test_full_name_equals
    @co.full_name = 'hi'

    assert_equal 'hi', @co.instance_variable_get(:@full_name)

    @co.full_name = nil

    assert_nil @co.instance_variable_get(:@full_name)
  end

  def test_ignore
    @co.ignore

    refute_predicate @co, :document_self
    refute_predicate @co, :document_children
    assert_predicate @co, :ignored?

    @store.options.visibility = :nodoc

    @co.store = @store

    assert_predicate @co, :document_self
    assert_predicate @co, :document_children
    refute_predicate @co, :ignored?

    @co.ignore

    refute_predicate @co, :ignored?
  end

  def test_ignore_eh
    refute_predicate @co, :ignored?

    @co.ignore

    assert_predicate @co, :ignored?
  end

  def test_line
    @c1_m.line = 5

    assert_equal 5, @c1_m.line
  end

  def test_metadata
    assert_empty @co.metadata

    @co.metadata['markup'] = 'not_rdoc'

    expected = { 'markup' => 'not_rdoc' }

    assert_equal expected, @co.metadata

    assert_equal 'not_rdoc', @co.metadata['markup']
  end

  def test_parent_name
    assert_equal '(unknown)', @co.parent_name
    assert_equal 'xref_data.rb', @c1.parent_name
    assert_equal 'C2', @c2_c3.parent_name
  end

  def test_received_ndoc
    @co.document_self = false
    refute_predicate @co, :received_nodoc

    @co.document_self = nil
    assert_predicate @co, :received_nodoc

    @co.document_self = true
  end

  def test_record_location
    @co.record_location @xref_data

    assert_equal 'xref_data.rb', @co.file.relative_name
  end

  def test_record_location_ignored
    @co.ignore
    @co.record_location @xref_data

    refute_predicate @co, :ignored?
  end

  def test_record_location_suppressed
    @co.suppress
    @co.record_location @xref_data

    refute_predicate @co, :suppressed?
  end

  def test_section
    parent = RDoc::Context.new
    section = parent.sections.first

    @co.parent = parent
    @co.instance_variable_set :@section, section

    assert_equal section, @co.section

    @co.instance_variable_set :@section, nil
    @co.instance_variable_set :@section_title, nil

    assert_equal section, @co.section

    @co.instance_variable_set :@section, nil
    @co.instance_variable_set :@section_title, 'new title'

    assert_equal 'new title', @co.section.title
  end

  def test_start_doc
    @co.document_self = false
    @co.document_children = false

    @co.start_doc

    assert_predicate @co, :document_self
    assert_predicate @co, :document_children
  end

  def test_start_doc_ignored
    @co.ignore

    @co.start_doc

    assert_predicate @co, :document_self
    assert_predicate @co, :document_children
    refute_predicate @co, :ignored?
  end

  def test_start_doc_suppressed
    @co.suppress

    @co.start_doc

    assert_predicate @co, :document_self
    assert_predicate @co, :document_children
    refute_predicate @co, :suppressed?
  end

  def test_store_equals
    @co.document_self = false

    @co.store = @store

    refute_predicate @co, :document_self

    @store.options.visibility = :nodoc

    @co.store = @store

    assert_predicate @co, :document_self
  end

  def test_stop_doc
    @co.document_self = true
    @co.document_children = true

    @co.stop_doc

    refute_predicate @co, :document_self
    refute_predicate @co, :document_children

    @store.options.visibility = :nodoc

    @co.store = @store

    assert_predicate @co, :document_self
    assert_predicate @co, :document_children

    @co.stop_doc

    assert_predicate @co, :document_self
    assert_predicate @co, :document_children
  end

  def test_suppress
    @co.suppress

    refute_predicate @co, :document_self
    refute_predicate @co, :document_children
    assert_predicate @co, :suppressed?

    @store.options.visibility = :nodoc

    @co.store = @store

    refute_predicate @co, :suppressed?

    @co.suppress

    refute_predicate @co, :suppressed?
  end

  def test_suppress_eh
    refute_predicate @co, :suppressed?

    @co.suppress

    assert_predicate @co, :suppressed?
  end

end
