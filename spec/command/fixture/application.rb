module Imp::Test::Fixtures::Commands
  class Verysilly < Imp::Command
  end

  class UsesCamelCase < Imp::Command
  end

  class HasSuperClass < UsesCamelCase
  end

  class CustomName < Imp::Command
    command 'hello'
  end

  class FromCustom < CustomName
  end
end