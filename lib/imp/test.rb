module Imp::Test
end

imp_test = File.join(File.dirname(__FILE__), 'test', '')

require imp_test + 'matchers'
