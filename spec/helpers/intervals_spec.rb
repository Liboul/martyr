require 'spec_helper'

def define_date_functions
  [0, 1, 2, 5, 10, 15, 20, 25, 30, 40, 45, 50, 80, 90, 100, 101, 150, 200, 250, 300, 350, 400, 500, 600].each do |x|
    let("d#{x}") { x.days.from_now }
  end
end

describe Martyr::Interval do
  define_date_functions

  describe 'initialize' do
    it 'does not allow from bigger than to: integers' do
      expect { Martyr::Interval.new 5, 5 }.to raise_error(Martyr::Error)
      expect { Martyr::Interval.new 5, [5] }.to raise_error(Martyr::Error)
      expect { Martyr::Interval.new [5], 5 }.to raise_error(Martyr::Error)
      expect { Martyr::Interval.new [5], [5] }.not_to raise_error
    end
    it 'does not allow from bigger than to: dates' do
      expect { Martyr::Interval.new d5, d5 }.to raise_error(Martyr::Error)
      expect { Martyr::Interval.new d5, [d5] }.to raise_error(Martyr::Error)
      expect { Martyr::Interval.new [d5], d5 }.to raise_error(Martyr::Error)
      expect { Martyr::Interval.new [d5], [d5] }.not_to raise_error
    end
  end

  describe 'overlap?' do
    context 'integers' do
      it 'is false when not overlapping on open intervals' do
        interval1 = Martyr::Interval.new 1, 5
        interval2 = Martyr::Interval.new 5, 10
        expect(interval1.overlap?(interval2)).to eq(false)
      end

      it 'is false when not overlapping on open and closed interval' do
        interval1 = Martyr::Interval.new 1, 5
        interval2 = Martyr::Interval.new [5], 10
        expect(interval1.overlap?(interval2)).to eq(false)
      end

      it 'is false when not overlapping on open and closed interval' do
        interval1 = Martyr::Interval.new 1, [5]
        interval2 = Martyr::Interval.new 5, 10
        expect(interval1.overlap?(interval2)).to eq(false)
      end

      it 'is true when overlapping on closed intervals' do
        interval1 = Martyr::Interval.new 1, [5]
        interval2 = Martyr::Interval.new [5], 10
        expect(interval1.overlap?(interval2)).to eq(true)
      end
    end

    context 'dates' do
      it 'is false when not overlapping on open intervals' do
        interval1 = Martyr::Interval.new d1, d5
        interval2 = Martyr::Interval.new d5, d10
        expect(interval1.overlap?(interval2)).to eq(false)
      end

      it 'is false when not overlapping on open and closed interval' do
        interval1 = Martyr::Interval.new d1, d5
        interval2 = Martyr::Interval.new [d5], d10
        expect(interval1.overlap?(interval2)).to eq(false)
      end

      it 'is false when not overlapping on open and closed interval' do
        interval1 = Martyr::Interval.new d1, [d5]
        interval2 = Martyr::Interval.new d5, d10
        expect(interval1.overlap?(interval2)).to eq(false)
      end

      it 'is true when overlapping on closed intervals' do
        interval1 = Martyr::Interval.new d1, [d5]
        interval2 = Martyr::Interval.new [d5], d10
        expect(interval1.overlap?(interval2)).to eq(true)
      end
    end
  end

  describe 'touch?' do
    context 'integers' do
      it 'is false when not overlapping on open intervals' do
        interval1 = Martyr::Interval.new 1, 5
        interval2 = Martyr::Interval.new 5, 10
        expect(interval1.touch?(interval2)).to eq(false)
      end

      it 'is true when not overlapping on open and closed interval' do
        interval1 = Martyr::Interval.new 1, 5
        interval2 = Martyr::Interval.new [5], 10
        expect(interval1.touch?(interval2)).to eq(true)
      end

      it 'is true when not overlapping on open and closed interval' do
        interval1 = Martyr::Interval.new 1, [5]
        interval2 = Martyr::Interval.new 5, 10
        expect(interval1.touch?(interval2)).to eq(true)
      end

      it 'is true when overlapping on closed intervals' do
        interval1 = Martyr::Interval.new 1, [5]
        interval2 = Martyr::Interval.new [5], 10
        expect(interval1.touch?(interval2)).to eq(true)
      end      
    end

    context 'dates' do
      it 'is false when not overlapping on open intervals' do
        interval1 = Martyr::Interval.new d1, d5
        interval2 = Martyr::Interval.new d5, d10
        expect(interval1.touch?(interval2)).to eq(false)
      end

      it 'is true when not overlapping on open and closed interval' do
        interval1 = Martyr::Interval.new d1, d5
        interval2 = Martyr::Interval.new [d5], d10
        expect(interval1.touch?(interval2)).to eq(true)
      end

      it 'is true when not overlapping on open and closed interval' do
        interval1 = Martyr::Interval.new d1, [d5]
        interval2 = Martyr::Interval.new d5, d10
        expect(interval1.touch?(interval2)).to eq(true)
      end

      it 'is true when overlapping on closed intervals' do
        interval1 = Martyr::Interval.new d1, [d5]
        interval2 = Martyr::Interval.new [d5], d10
        expect(interval1.touch?(interval2)).to eq(true)
      end
    end
  end

  describe 'intersect' do
    context 'integers' do
      it 'returns nil when not overlapping on open intervals' do
        interval1 = Martyr::Interval.new 1, 5
        interval2 = Martyr::Interval.new 5, 10
        expect(interval1.intersect(interval2)).to eq(nil)
      end

      it 'returns nil when not overlapping on open and closed interval' do
        interval1 = Martyr::Interval.new 1, 5
        interval2 = Martyr::Interval.new [5], 10
        expect(interval1.intersect(interval2)).to eq(nil)
      end

      it 'returns nil when not overlapping on open and closed interval' do
        interval1 = Martyr::Interval.new 1, [5]
        interval2 = Martyr::Interval.new 5, 10
        expect(interval1.intersect(interval2)).to eq(nil)
      end

      it 'returns the intersect when overlapping on a point' do
        interval1 = Martyr::Interval.new 1, [5]
        interval2 = Martyr::Interval.new [5], 10
        x = interval1.intersect(interval2)
        expect(x.from.to_param).to eq([5])
        expect(x.to.to_param).to eq([5])
      end

      it 'returns the intersect of fully contained' do
        interval1 = Martyr::Interval.new 1, 20
        interval2 = Martyr::Interval.new 5, 10
        x = interval1.intersect(interval2)
        expect(x.from.to_param).to eq(5)
        expect(x.to.to_param).to eq(10)
      end

      it 'returns the intersect of partially contained on the right' do
        interval1 = Martyr::Interval.new 10, 20
        interval2 = Martyr::Interval.new 15, 25
        x = interval1.intersect(interval2)
        expect(x.from.to_param).to eq(15)
        expect(x.to.to_param).to eq(20)
      end

      it 'returns the intersect of partially contained on the left' do
        interval1 = Martyr::Interval.new 10, 20
        interval2 = Martyr::Interval.new 5, 15
        x = interval1.intersect(interval2)
        expect(x.from.to_param).to eq(10)
        expect(x.to.to_param).to eq(15)
      end

      it 'returns the intersect of identical' do
        interval1 = Martyr::Interval.new 10, 20
        interval2 = Martyr::Interval.new 10, 20
        x = interval1.intersect(interval2)
        expect(x.from.to_param).to eq(10)
        expect(x.to.to_param).to eq(20)
      end

      it 'overrides closed with open' do
        interval1 = Martyr::Interval.new [10], [20]
        interval2 = Martyr::Interval.new 10, 20
        x = interval1.intersect(interval2)
        expect(x.from.to_param).to eq(10)
        expect(x.to.to_param).to eq(20)
      end      
    end

    context 'dates' do
      it 'returns nil when not overlapping on open intervals' do
        interval1 = Martyr::Interval.new d1, d5
        interval2 = Martyr::Interval.new d5, d10
        expect(interval1.intersect(interval2)).to eq(nil)
      end

      it 'returns nil when not overlapping on open and closed interval' do
        interval1 = Martyr::Interval.new d1, d5
        interval2 = Martyr::Interval.new [d5], d10
        expect(interval1.intersect(interval2)).to eq(nil)
      end

      it 'returns nil when not overlapping on open and closed interval' do
        interval1 = Martyr::Interval.new d1, [d5]
        interval2 = Martyr::Interval.new d5, d10
        expect(interval1.intersect(interval2)).to eq(nil)
      end

      it 'returns the intersect when overlapping on a point' do
        interval1 = Martyr::Interval.new d1, [d5]
        interval2 = Martyr::Interval.new [d5], d10
        x = interval1.intersect(interval2)
        expect(x.from.to_param).to eq([d5])
        expect(x.to.to_param).to eq([d5])
      end

      it 'returns the intersect of fully contained' do
        interval1 = Martyr::Interval.new d1, d20
        interval2 = Martyr::Interval.new d5, d10
        x = interval1.intersect(interval2)
        expect(x.from.to_param).to eq(d5)
        expect(x.to.to_param).to eq(d10)
      end

      it 'returns the intersect of partially contained on the right' do
        interval1 = Martyr::Interval.new d10, d20
        interval2 = Martyr::Interval.new d15, d25
        x = interval1.intersect(interval2)
        expect(x.from.to_param).to eq(d15)
        expect(x.to.to_param).to eq(d20)
      end

      it 'returns the intersect of partially contained on the left' do
        interval1 = Martyr::Interval.new d10, d20
        interval2 = Martyr::Interval.new d5, d15
        x = interval1.intersect(interval2)
        expect(x.from.to_param).to eq(d10)
        expect(x.to.to_param).to eq(d15)
      end

      it 'returns the intersect of identical' do
        interval1 = Martyr::Interval.new d10, d20
        interval2 = Martyr::Interval.new d10, d20
        x = interval1.intersect(interval2)
        expect(x.from.to_param).to eq(d10)
        expect(x.to.to_param).to eq(d20)
      end

      it 'overrides closed with open' do
        interval1 = Martyr::Interval.new [d10], [d20]
        interval2 = Martyr::Interval.new d10, d20
        x = interval1.intersect(interval2)
        expect(x.from.to_param).to eq(d10)
        expect(x.to.to_param).to eq(d20)
      end
    end
  end

  describe 'union' do
    context 'integers' do
      it 'returns nil when not touching' do
        interval1 = Martyr::Interval.new 1, 5
        interval2 = Martyr::Interval.new 5, 10
        expect(interval1.union(interval2)).to eq(nil)
      end

      it 'returns the union when overlapping on a point' do
        interval1 = Martyr::Interval.new 1, [5]
        interval2 = Martyr::Interval.new 5, 10
        x = interval1.union(interval2)
        expect(x.from.to_param).to eq(1)
        expect(x.to.to_param).to eq(10)
      end

      it 'returns the union of fully contained' do
        interval1 = Martyr::Interval.new 1, 20
        interval2 = Martyr::Interval.new 5, 10
        x = interval1.union(interval2)
        expect(x.from.to_param).to eq(1)
        expect(x.to.to_param).to eq(20)
      end

      it 'returns the union of partially contained on the right' do
        interval1 = Martyr::Interval.new 10, 20
        interval2 = Martyr::Interval.new 15, 25
        x = interval1.union(interval2)
        expect(x.from.to_param).to eq(10)
        expect(x.to.to_param).to eq(25)
      end

      it 'returns the union of partially contained on the left' do
        interval1 = Martyr::Interval.new 10, 20
        interval2 = Martyr::Interval.new 5, 15
        x = interval1.union(interval2)
        expect(x.from.to_param).to eq(5)
        expect(x.to.to_param).to eq(20)
      end

      it 'returns the union of identical' do
        interval1 = Martyr::Interval.new 10, 20
        interval2 = Martyr::Interval.new 10, 20
        x = interval1.union(interval2)
        expect(x.from.to_param).to eq(10)
        expect(x.to.to_param).to eq(20)
      end

      it 'overrides open with closed' do
        interval1 = Martyr::Interval.new [10], [20]
        interval2 = Martyr::Interval.new 10, 20
        x = interval1.union(interval2)
        expect(x.from.to_param).to eq([10])
        expect(x.to.to_param).to eq([20])
      end
    end

    context 'dates' do
      it 'returns nil when not touching' do
        interval1 = Martyr::Interval.new d1, d5
        interval2 = Martyr::Interval.new d5, d10
        expect(interval1.union(interval2)).to eq(nil)
      end

      it 'returns the union when overlapping on a point' do
        interval1 = Martyr::Interval.new d1, [d5]
        interval2 = Martyr::Interval.new d5, d10
        x = interval1.union(interval2)
        expect(x.from.to_param).to eq(d1)
        expect(x.to.to_param).to eq(d10)
      end

      it 'returns the union of fully contained' do
        interval1 = Martyr::Interval.new d1, d20
        interval2 = Martyr::Interval.new d5, d10
        x = interval1.union(interval2)
        expect(x.from.to_param).to eq(d1)
        expect(x.to.to_param).to eq(d20)
      end

      it 'returns the union of partially contained on the right' do
        interval1 = Martyr::Interval.new d10, d20
        interval2 = Martyr::Interval.new d15, d25
        x = interval1.union(interval2)
        expect(x.from.to_param).to eq(d10)
        expect(x.to.to_param).to eq(d25)
      end

      it 'returns the union of partially contained on the left' do
        interval1 = Martyr::Interval.new d10, d20
        interval2 = Martyr::Interval.new d5, d15
        x = interval1.union(interval2)
        expect(x.from.to_param).to eq(d5)
        expect(x.to.to_param).to eq(d20)
      end

      it 'returns the union of identical' do
        interval1 = Martyr::Interval.new d10, d20
        interval2 = Martyr::Interval.new d10, d20
        x = interval1.union(interval2)
        expect(x.from.to_param).to eq(d10)
        expect(x.to.to_param).to eq(d20)
      end

      it 'overrides open with closed' do
        interval1 = Martyr::Interval.new [d10], [d20]
        interval2 = Martyr::Interval.new d10, d20
        x = interval1.union(interval2)
        expect(x.from.to_param).to eq([d10])
        expect(x.to.to_param).to eq([d20])
      end
    end
  end
end

describe Martyr::IntervalSet do
  define_date_functions

  context 'integers' do
    describe 'add' do
      it 'does not join when adding non touching intervals' do
        set = Martyr::IntervalSet.new
        set.add from: 5, to: 20
        set.add from: 20, to: 30
        expect(set.set.length).to eq(2)
        expect(set.set.first.from.to_param).to eq(5)
        expect(set.set.first.to.to_param).to eq(20)
        expect(set.set.second.from.to_param).to eq(20)
        expect(set.set.second.to.to_param).to eq(30)
      end

      it 'joins when adding non touching intervals' do
        set = Martyr::IntervalSet.new
        set.add from: 5, to: 20
        set.add from: [20], to: 30
        expect(set.set.length).to eq(1)
        expect(set.set.first.from.to_param).to eq(5)
        expect(set.set.first.to.to_param).to eq(30)
      end

      it 'handles correctly complex case' do
        set = Martyr::IntervalSet.new
        set.add from: 100, to: 200
        set.add from: 300, to: 400
        set.add from: 500, to: 600
        set.add from: 150, to: 350

        expect(set.set.length).to eq(2)
        expect(set.set.first.from.to_param).to eq(100)
        expect(set.set.first.to.to_param).to eq(400)
        expect(set.set.second.from.to_param).to eq(500)
        expect(set.set.second.to.to_param).to eq(600)
      end

      it 'handles correctly partial intervals' do
        set = Martyr::IntervalSet.new
        set.add to: 200
        set.add from: 300
        set.add from: [200], to: [300]
        expect(set.set.length).to eq(1)
        expect(set.set.first.from.to_param).to eq(-Float::INFINITY)
        expect(set.set.first.to.to_param).to eq(Float::INFINITY)
      end
    end

    describe 'intersect' do
      it 'handles correctly identical sets with one element' do
        set1 = Martyr::IntervalSet.new
        set2 = Martyr::IntervalSet.new
        set1.add from: 5, to: 20
        set2.add from: 5, to: 20
        set3 = set1.intersect(set2)
        expect(set3.set.length).to eq(1)
        expect(set3.set.first.from.to_param).to eq(5)
        expect(set3.set.first.to.to_param).to eq(20)
      end

      it 'handles correctly identical sets with two element' do
        set1 = Martyr::IntervalSet.new
        set2 = Martyr::IntervalSet.new
        set1.add from: 5, to: 20
        set1.add from: 20, to: 30
        set2.add from: 5, to: 20
        set2.add from: 20, to: 30
        set3 = set1.intersect(set2)
        expect(set3.set.length).to eq(2)
        expect(set3.set.first.from.to_param).to eq(5)
        expect(set3.set.first.to.to_param).to eq(20)
        expect(set3.set.second.from.to_param).to eq(20)
        expect(set3.set.second.to.to_param).to eq(30)
      end

      it 'handles correctly complex case' do
        set1 = Martyr::IntervalSet.new
        set2 = Martyr::IntervalSet.new
        set1.add from: 10, to: 20
        set1.add from: 30, to: 40

        set2.add from: 15, to: 25
        set2.add from: 45, to: 50
        set3 = set1.intersect(set2)

        expect(set3.set.length).to eq(1)
        expect(set3.set.first.from.to_param).to eq(15)
        expect(set3.set.first.to.to_param).to eq(20)
      end

      it 'handles correctly partial intervals' do
        set1 = Martyr::IntervalSet.new
        set2 = Martyr::IntervalSet.new
        set1.add to: 100
        set1.add from: 200

        set2.add from: 0, to: 80
        set2.add from: 90
        set3 = set1.intersect(set2)

        expect(set3.set.length).to eq(3)
        expect(set3.set.first.from.to_param).to eq(0)
        expect(set3.set.first.to.to_param).to eq(80)
        expect(set3.set.second.from.to_param).to eq(90)
        expect(set3.set.second.to.to_param).to eq(100)
        expect(set3.set.third.from.to_param).to eq(200)
        expect(set3.set.third.to.to_param).to eq(Float::INFINITY)
      end
    end

    describe 'extract_and_fill_holes' do
      it 'does nothing when there are no holes' do
        set = Martyr::IntervalSet.new
        set.add(to: 100).add(from: 101)

        expect(set.extract_and_fill_holes).to eq([])
        expect(set.set.length).to eq(2)
        expect(set.set.first.from.to_param).to eq(-Float::INFINITY)
        expect(set.set.first.to.to_param).to eq(100)
        expect(set.set.second.from.to_param).to eq(101)
        expect(set.set.second.to.to_param).to eq(Float::INFINITY)
      end

      it 'fills holes when they exist' do
        set = Martyr::IntervalSet.new.add(from: 0, to: 100).add(from: 200, to: 300)
        hole1 = Martyr::IntervalSet.new.add(to: 50).add(from: 50)
        hole2 = Martyr::IntervalSet.new.add(to: 250).add(from: 250)
        set.intersect(hole1).intersect(hole2)

        expect(set.extract_and_fill_holes).to eq([50, 250])
        expect(set.set.length).to eq(2)
        expect(set.set.first.from.to_param).to eq(0)
        expect(set.set.first.to.to_param).to eq(100)
        expect(set.set.second.from.to_param).to eq(200)
        expect(set.set.second.to.to_param).to eq(300)
      end
    end

    describe 'extract_and_remove_points' do
      it 'does nothing when there are no points' do
        set = Martyr::IntervalSet.new
        set.add(to: 100).add(from: 101)

        expect(set.extract_and_remove_points).to eq([])
        expect(set.set.length).to eq(2)
        expect(set.set.first.from.to_param).to eq(-Float::INFINITY)
        expect(set.set.first.to.to_param).to eq(100)
        expect(set.set.second.from.to_param).to eq(101)
        expect(set.set.second.to.to_param).to eq(Float::INFINITY)
      end

      it 'extract points when they exist' do
        set = Martyr::IntervalSet.new.add(from: [50], to: [50]).add(from: [100], to: [100])

        expect(set.extract_and_remove_points).to eq([50, 100])
        expect(set.set.length).to eq(0)
      end
    end    
  end
  
  context 'dates' do
    describe 'add' do
      it 'does not join when adding non touching intervals' do
        set = Martyr::IntervalSet.new
        set.add from: d5, to: d20
        set.add from: d20, to: d30
        expect(set.set.length).to eq(2)
        expect(set.set.first.from.to_param).to eq(d5)
        expect(set.set.first.to.to_param).to eq(d20)
        expect(set.set.second.from.to_param).to eq(d20)
        expect(set.set.second.to.to_param).to eq(d30)
      end

      it 'joins when adding non touching intervals' do
        set = Martyr::IntervalSet.new
        set.add from: d5, to: d20
        set.add from: [d20], to: d30
        expect(set.set.length).to eq(1)
        expect(set.set.first.from.to_param).to eq(d5)
        expect(set.set.first.to.to_param).to eq(d30)
      end

      it 'handles correctly complex case' do
        set = Martyr::IntervalSet.new
        set.add from: d100, to: d200
        set.add from: d300, to: d400
        set.add from: d500, to: d600
        set.add from: d150, to: d350

        expect(set.set.length).to eq(2)
        expect(set.set.first.from.to_param).to eq(d100)
        expect(set.set.first.to.to_param).to eq(d400)
        expect(set.set.second.from.to_param).to eq(d500)
        expect(set.set.second.to.to_param).to eq(d600)
      end

      it 'handles correctly partial intervals' do
        set = Martyr::IntervalSet.new
        set.add to: d200
        set.add from: d300
        set.add from: [d200], to: [d300]
        expect(set.set.length).to eq(1)
        expect(set.set.first.from.to_param).to eq(-Float::INFINITY)
        expect(set.set.first.to.to_param).to eq(Float::INFINITY)
      end
    end

    describe 'intersect' do
      it 'handles correctly identical sets with one element' do
        set1 = Martyr::IntervalSet.new
        set2 = Martyr::IntervalSet.new
        set1.add from: d5, to: d20
        set2.add from: d5, to: d20
        set3 = set1.intersect(set2)
        expect(set3.set.length).to eq(1)
        expect(set3.set.first.from.to_param).to eq(d5)
        expect(set3.set.first.to.to_param).to eq(d20)
      end

      it 'handles correctly identical sets with two element' do
        set1 = Martyr::IntervalSet.new
        set2 = Martyr::IntervalSet.new
        set1.add from: d5, to: d20
        set1.add from: d20, to: d30
        set2.add from: d5, to: d20
        set2.add from: d20, to: d30
        set3 = set1.intersect(set2)
        expect(set3.set.length).to eq(2)
        expect(set3.set.first.from.to_param).to eq(d5)
        expect(set3.set.first.to.to_param).to eq(d20)
        expect(set3.set.second.from.to_param).to eq(d20)
        expect(set3.set.second.to.to_param).to eq(d30)
      end

      it 'handles correctly complex case' do
        set1 = Martyr::IntervalSet.new
        set2 = Martyr::IntervalSet.new
        set1.add from: d10, to: d20
        set1.add from: d30, to: d40

        set2.add from: d15, to: d25
        set2.add from: d45, to: d50
        set3 = set1.intersect(set2)

        expect(set3.set.length).to eq(1)
        expect(set3.set.first.from.to_param).to eq(d15)
        expect(set3.set.first.to.to_param).to eq(d20)
      end

      it 'handles correctly partial intervals' do
        set1 = Martyr::IntervalSet.new
        set2 = Martyr::IntervalSet.new
        set1.add to: d100
        set1.add from: d200

        set2.add from: d0, to: d80
        set2.add from: d90
        set3 = set1.intersect(set2)

        expect(set3.set.length).to eq(3)
        expect(set3.set.first.from.to_param).to eq(d0)
        expect(set3.set.first.to.to_param).to eq(d80)
        expect(set3.set.second.from.to_param).to eq(d90)
        expect(set3.set.second.to.to_param).to eq(d100)
        expect(set3.set.third.from.to_param).to eq(d200)
        expect(set3.set.third.to.to_param).to eq(Float::INFINITY)
      end
    end

    describe 'extract_and_fill_holes' do
      it 'does nothing when there are no holes' do
        set = Martyr::IntervalSet.new
        set.add(to: d100).add(from: d101)

        expect(set.extract_and_fill_holes).to eq([])
        expect(set.set.length).to eq(2)
        expect(set.set.first.from.to_param).to eq(-Float::INFINITY)
        expect(set.set.first.to.to_param).to eq(d100)
        expect(set.set.second.from.to_param).to eq(d101)
        expect(set.set.second.to.to_param).to eq(Float::INFINITY)
      end

      it 'fills holes when they exist' do
        set = Martyr::IntervalSet.new.add(from: d0, to: d100).add(from: d200, to: d300)
        hole1 = Martyr::IntervalSet.new.add(to: d50).add(from: d50)
        hole2 = Martyr::IntervalSet.new.add(to: d250).add(from: d250)
        set.intersect(hole1).intersect(hole2)

        expect(set.extract_and_fill_holes).to eq([d50, d250])
        expect(set.set.length).to eq(2)
        expect(set.set.first.from.to_param).to eq(d0)
        expect(set.set.first.to.to_param).to eq(d100)
        expect(set.set.second.from.to_param).to eq(d200)
        expect(set.set.second.to.to_param).to eq(d300)
      end
    end

    describe 'extract_and_remove_points' do
      it 'does nothing when there are no points' do
        set = Martyr::IntervalSet.new
        set.add(to: d100).add(from: d101)

        expect(set.extract_and_remove_points).to eq([])
        expect(set.set.length).to eq(2)
        expect(set.set.first.from.to_param).to eq(-Float::INFINITY)
        expect(set.set.first.to.to_param).to eq(d100)
        expect(set.set.second.from.to_param).to eq(d101)
        expect(set.set.second.to.to_param).to eq(Float::INFINITY)
      end

      it 'extract points when they exist' do
        set = Martyr::IntervalSet.new.add(from: [d50], to: [d50]).add(from: [d100], to: [d100])

        expect(set.extract_and_remove_points).to eq([d50, d100])
        expect(set.set.length).to eq(0)
      end
    end    
  end


end
