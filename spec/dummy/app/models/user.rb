class User < ApplicationRecord
  searchable do
    text(:name)
  end
end
