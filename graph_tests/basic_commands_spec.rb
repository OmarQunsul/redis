require 'redis'

redis = Redis.new

describe 'basic commands' do
  before do
    redis.flushdb
    redis.gnode 'graph1', 'a', 'b', 'c', 'd', 'e', 'f', 'j'
    redis.gedge 'graph1', 'a', 'b', 2
    redis.gedge 'graph1', 'a', 'c', 1
    redis.gedge 'graph1', 'c', 'd', 10
    redis.gedge 'graph1', 'c', 'e', 3
    redis.gedge 'graph1', 'b', 'd', 4
    redis.gedge 'graph1', 'd', 'e', 5
    redis.gedge 'graph1', 'd', 'f', 2
  end

  it "should return the correct type for the graph object key" do
    ret = redis.type('graph1')
    expect(ret).to eq('graph')
  end

  it 'should generate correct neighbours' do
    redis.gneighbours('graph1', 'a').sort.should eq ['b', 'c']
    redis.gneighbours('graph1', 'b').should eq ['a', 'd']
    redis.gneighbours('graph1', 'f').should eq ['d']
    redis.gneighbours('graph1', 'j').should eq []
  end

  it 'should generate correct common neighbours' do
    redis.gcommon('graph1', 'a', 'd').sort.should eq ['b', 'c']
    redis.gcommon('graph1', 'a', 'f').should eq []
  end

  it 'should tell correctly whether node exists or not' do
    redis.gnodeexists('graph1', 'a').should eq 1
    redis.gnodeexists('graph1', 'z').should eq 0
  end

  it 'should return the correct values for edges' do
    redis.gedgeexists('graph1', 'a', 'd').should eq 0
    redis.gedgeexists('graph1', 'a', 'c').should eq 1
    redis.gedgevalue('graph1', 'a', 'b').should eq "2"
    redis.gedgevalue('graph1', 'd', 'c').should eq "10"
  end

  it 'should be able to remove edge' do
    redis.gedgerem('graph1', 'b', 'd')
    redis.gedgeexists('graph1', 'b', 'd').should eq 0
    redis.gcommon('graph1', 'a', 'd').should eq ['c']
    redis.gneighbours('graph1', 'b').should eq ['a']

    redis.gedge('graph1', 'b', 'd', 4)
    redis.gedgeexists('graph1', 'b', 'd').should eq 1
    redis.gedgevalue('graph1', 'b', 'd').should eq "4"
  end

  it "should return nil for edge value that does not exist" do
    value = redis.gedgevalue('graph1', 'a', 'g')
    expect(value).to eq(nil)
  end

  it "should handle float numbers for edge values" do
    redis.gedge 'graph1', 'a', 'g', 1.5
    returned_value = redis.gedgevalue 'graph1', 'a', 'g'
    expect(returned_value).to eq("1.5")
  end
end
