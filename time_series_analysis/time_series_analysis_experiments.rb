# Test data is structured as [time_series, is_trend]
test_data = [[[1,  3,  2, 1, 2, 4, 8, 10], true],
             [[1,  3,  2, 1, 2, 3, 1, 2],  false],
             [[1,  1,  1, 1, 1, 1, 1, 1],  false],
             [[10, 8,  4, 1, 1, 1, 1, 1],  false],
             [[20, 10, 4, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],  false],
             [[1,  1,  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],  false],
             [[2,  1,  2, 3, 2, 3, 2, 1, 1, 3, 2, 1, 2, 2, 3, 2],  false],
             [[2,  1,  2, 3, 2, 3, 2, 1, 1, 3, 2, 1, 2, 4, 8, 10], true],
             [[0,  1,  0, 0, 577,124,54,13,10], false],
             [[0,  0,  0, 1, 0,0,673,224,78], false],
             [[0,  0,  0, 0, 0,0,265,51,19], false],
             [[0,  0,  0, 0, 265,51,16,86,29], false],
             [[0,  0,  0, 0, 0,0,91,86,28], false],
             [[0,  0,  0, 0, 0,167,50,11,27], false],
             [[0,  0,  0, 0, 0,40,17,11,4], false],
             [[0,  0,  0, 0, 0, 0, 0, 0 ,20], true],
             [[0,  0,  0, 0, 0, 0, 0, 0 ,30], true],
             [[0,  0,  0, 0, 0, 0, 0, 0 ,40], true],
             [[0,  0,  0, 0, 0, 0, 20,30,40], true],
             [[4,15,9,10,9,4,14,8,9], false],
             [[11,25,89,36,20,44,21,12,3], false],
             [[1,2,3,10,1,1,2,10,9], false],
             [[0,13,12,17,44,18,11,3,3], false],
             [[0,0,0,0,0,35,0,0,0], false],
             [[1,2,1,3,2,1,2,7,8], true],
             [[2,3,2,6,3,2,1,0,0], false],
             [[3,11,17,6,6,6,6,11,1], false],
             [[3,0,0,0,0,0,0,2,0], false],
             [[3,4,3,5,5,3,11,3,1], false],
             [[3,6,6,6,6,11,1,4,5], false],
             [[39,51,16,86,36,20,45,19,9], false],
             [[6,1,3,1,2,2,3,4,2], false],
             [[2,3,5,2,1,3,3,3,1], false],
             [[2,20,13,16,21,9,8,8,6], false],
             [[2,3,4,4,6,16,18,16,21], true],
             [[3,0,0,0,0,1,0,0,0], false],
             [[116,224,105,39,27,23,50,22,11], false],
             [[0,0,1,0,2,1,1,1,0], false]]


def evaluate_test_case(test_data, func, verbose=false)
  failed_list = []
  test_data.each do |test_case|
    failed = test_case[1] != func.call(test_case[0], verbose)
    failed_list += [test_case] if failed
    puts "Processing: #{test_case}"
    puts (if failed then "!!! F A I L E D !!!" else "==> Success!!!" end) 
  end
  puts "TOTAL FAILURES: #{failed_list.length}/#{test_data.length}"
  return failed_list
end

def median(array)
  sorted = array.sort
  len = sorted.length
  return (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
end

home_made_approach_1 = Proc.new do |time_series, verbose=false|
  # a) Obtain mu as median
  mu = median(time_series)
  
  puts "a) mu: #{mu}" if verbose

  # b) Only for values greater than the mu, indicate the difference
  time_series_diff = time_series.map{|t| if t <= mu then 0.0 else (t - mu) end }
  
  puts "b): #{time_series_diff}" if verbose

  # c) Map to percentage values
  time_series_diff_perc = time_series_diff.map{|t| (t.to_f / (mu + 0.01)).round(3) }
  
  puts "c): #{time_series_diff_perc}" if verbose

  # d) Consider only those values more than 50% above mu
  time_series_diff_perc_filtered = time_series_diff_perc.map{|t| if t <= 0.5 then 0.0  else t end}
  
  puts "d): #{time_series_diff_perc_filtered}" if verbose
      
  if time_series_diff_perc_filtered.inject(:+) > 0
      
    # e) Create a sorted version of time_series values
    sorted_time_series_diff_perc_filtered = time_series_diff_perc_filtered.sort
    
    puts "e): #{sorted_time_series_diff_perc_filtered}" if verbose
        
    # f) Perform an element-wise subtraction between the list and the sorted version (e)

    element_wise_diff = time_series_diff_perc.each_with_index.map { |t,i| if [t, sorted_time_series_diff_perc_filtered[i]].max == 0 then 1.0 
                                                                          else ([t, sorted_time_series_diff_perc_filtered[i]].min.to_f / 
                                                                                [t, sorted_time_series_diff_perc_filtered[i]].max.to_f).round(3) end }
    puts "f): #{element_wise_diff}" if verbose

    # g) Give different weight in the diff of zeros
    element_wise_diff = element_wise_diff.each_with_index.map { |t,i| if (time_series_diff_perc_filtered[i] +
                                                  sorted_time_series_diff_perc_filtered[i]) == 0 then 0.5 else t end }
    
    puts "g): #{element_wise_diff}" if verbose

    # h) Calculate de mean of element_wise_diff. The closer to 1.0 the more likely to be trend
    mean_element_wise_diff = (element_wise_diff.reduce(:+).to_f / element_wise_diff.length).round(3)
    
    puts "h): #{mean_element_wise_diff}" if verbose

    is_time_series = mean_element_wise_diff > 0.55
  else
    is_time_series = false 
  end

  is_time_series
end


failed_cases = evaluate_test_case(test_data, home_made_approach_1, verbose=false)

evaluate_test_case(failed_cases, home_made_approach_1, verbose=true)

