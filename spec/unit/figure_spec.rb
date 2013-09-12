require "ashikawa-core/figure"

describe Ashikawa::Core::Figure do
  let(:raw_figures) {
    {
      "alive" => {
        "size" => 0,
        "count" => 0
      },
      "dead" => {
        "size" => 2384,
        "count" => 149,
        "deletion" => 0
      },
      "datafiles" => {
        "count" => 1,
        "fileSize" => 124
      },
      "journals" => {
        "count" => 1,
        "fileSize" => 124
      },
      "shapes" => {
        "count" => 2
      },
      "attributes" => {
        "count" => 12
      }
    }
  }
  subject { Ashikawa::Core::Figure.new(raw_figures) }

  it "should check for the alive figures" do
    expect(subject.alive_size).to eq(0)
    expect(subject.alive_count).to eq(0)
  end

  it "should check for the dead figures" do
    expect(subject.dead_size).to eq(2384)
    expect(subject.dead_count).to eq(149)
    expect(subject.dead_deletion).to eq(0)
  end

  it "should check for the datafiles figures" do
    expect(subject.datafiles_count).to eq(1)
    expect(subject.datafiles_file_size).to eq(124)
  end

  it "should check for the journal figures" do
    expect(subject.journals_count).to eq(1)
    expect(subject.journals_file_size).to eq(124)
  end

  it "should check for the shapes figure" do
    expect(subject.shapes_count).to eq(2)
  end

  it "should check for the attributes_count figure" do
    expect(subject.attributes_count).to eq(12)
  end
end
