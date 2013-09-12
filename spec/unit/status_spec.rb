require "ashikawa-core/status"

describe Ashikawa::Core::Status do
  subject { Ashikawa::Core::Status }
  let(:status_codes) { (1..6).to_a }

  it "should know if the collection is new born" do
    status = subject.new 1
    expect(status.new_born?).to eq(true)

    (status_codes - [1]).each do |status_code|
      status = subject.new status_code
      expect(status.new_born?).to eq(false)
    end
  end

  it "should know if the collection is unloaded" do
    status = subject.new 2
    expect(status.unloaded?).to eq(true)

    (status_codes - [2]).each do |status_code|
      status = subject.new status_code
      expect(status.unloaded?).to eq(false)
    end
  end

  it "should know if the collection is loaded" do
    status = subject.new 3
    expect(status.loaded?).to eq(true)

    (status_codes - [3]).each do |status_code|
      status = subject.new status_code
      expect(status.loaded?).to eq(false)
    end
  end

  it "should know if the collection is being unloaded" do
    status = subject.new 4
    expect(status.being_unloaded?).to eq(true)

    (status_codes - [4]).each do |status_code|
      status = subject.new status_code
      expect(status.being_unloaded?).to eq(false)
    end
  end

  it "should know if the collection is corrupted" do
    status = subject.new 6
    expect(status.corrupted?).to eq(true)
  end
end
