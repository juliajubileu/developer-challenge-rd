require 'minitest/autorun'
require 'timeout'
class CustomerSuccessBalancing
  def initialize(customer_success, customers, customer_success_away)
    @customer_success = customer_success
    @customers = customers
    @customer_success_away = customer_success_away
  end

  def execute
    active_css = filter_active_css

    combined_customers = combine_css_and_customers_by_score(active_css)

    select_busiest_cs_id(combined_customers)
  end

  private

  def filter_active_css
    @customer_success.reject { |css| @customer_success_away.include?(css[:id]) }
  end

  def sort_scores(group)
    group.map { |g| g[:score] }.sort!
  end

  def combine_css_and_customers_by_score(active_css)
    combined_customers = {}
    customer_sizes = sort_scores(@customers)
    css_scores = sort_scores(active_css)

    css_scores.each do |cs_score|
      customers_for_cs = []
      last_index = -1

      break if customer_sizes.empty?

      customer_sizes.each_with_index do |customer_size, index|
        if customer_size <= cs_score
          customers_for_cs << customer_size
          last_index = index
        else
          break
        end
      end

      customer_sizes = customer_sizes[(last_index + 1)..-1]

      combined_customers[cs_score] = customers_for_cs unless customers_for_cs.empty?
    end
    combined_customers
  end

  def select_busiest_cs_id(combined_customers)
    busiest_css = combined_customers
                  .max_by(2) { |customer_group| customer_group[1].size }

    if busiest_css.empty? || busiest_css_tie?(busiest_css)
      0
    else
      busiest_cs_score = busiest_css[0][0]
      get_id_from_score(busiest_cs_score)
    end
  end

  def get_id_from_score(cs_score)
    css = @customer_success.select { |cs| cs[:score] == cs_score }
    id = css.first[:id]
  end

  def busiest_css_tie?(busiest_css)
    busiest_css.size > 1 && busiest_css[0][1].size == busiest_css[1][1].size
  end
end

class TestCustomerSuccessBalancing < Minitest::Test
  def test_scenario_one
    css = [{ id: 1, score: 60 }, { id: 2, score: 20 }, { id: 3, score: 95 }, { id: 4, score: 75 }]
    customers = [{ id: 1, score: 90 }, { id: 2, score: 20 }, { id: 3, score: 70 }, { id: 4, score: 40 }, { id: 5, score: 60 }, { id: 6, score: 10}]

    balancer = CustomerSuccessBalancing.new(css, customers, [2, 4])
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    css = array_to_map([11, 21, 31, 3, 4, 5])
    customers = array_to_map( [10, 10, 10, 20, 20, 30, 30, 30, 20, 60])
    balancer = CustomerSuccessBalancing.new(css, customers, [])
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    customer_success = (1..999).to_a
    customers = Array.new(10000, 998)

    balancer = CustomerSuccessBalancing.new(array_to_map(customer_success), array_to_map(customers), [999])

    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(array_to_map([1, 2, 3, 4, 5, 6]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [])
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(array_to_map([100, 2, 3, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [])
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(array_to_map([100, 99, 88, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [1, 3, 2])
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(array_to_map([100, 99, 88, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [4, 5, 6])
    assert_equal 3, balancer.execute
  end

  def test_scenario_eight
    customers = (1..9999).to_a

    balancer = CustomerSuccessBalancing.new(array_to_map([100, 998, 500, 200]), array_to_map(customers), [])

    result = Timeout.timeout(0.01) { balancer.execute }
    assert_equal 2, result
  end

  def array_to_map(arr)
    out = []
    arr.each_with_index { |score, index| out.push({ id: index + 1, score: score }) }
    out
  end
end

Minitest.run