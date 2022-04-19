# ActiveRecord association inheritance

 - Makes models inherit specified attributes from an association.
 - Scope queries by inherited attributes

Supports ActiveRecord 5.0, 5.1, 5.2, 6.0, 6.1

## Install

```
gem install active_record_inherit_assoc
```

## Usage

### Filling inherited attributes on initialization:
```Ruby
# parent_name - The Symbol name of the parent association.
# options     - The Hash options to use:
#               :attr - A Symbol or an Array of Symbol names of the attributes
#                       that should be inherited from the parent association.
#
class Post < ActiveRecord::Base
  belongs_to :category
  inherits_from :category, attr: :account
end
```

### Scoping queries

```Ruby
class Post < ActiveRecord::Base
  has_many :categories, inherit: :account_id
end

post = Post.first
post.categories.build.account_id == post.account_id # fills attribute on new objects
post.categories.to_sql # adds inherited attributes to queries
```

This is similar to adding a scope `{ |record| where(account_id: record.account_id) }`,
but also allows to do `Post.all.includes(:categories)` to work by filtering preloaded records.
This will not use the attribute to query, so it might use a different index and find more than neccessary records.

#### Allowed list of values (inherit_allowed_list)

In some occasions, there are values that we don't want to filter out, even if they don't correspond to the inherited one.
Following the previous Post example, this could happen if we have a universal "system" category belonging to no account, one that we associated to all the posts that have no other category. A way to keep this category (assuming that it has the account_id `-1`) would look like this:

```Ruby
class Post < ActiveRecord::Base
  has_many :categories, inherit: :account_id, inherit_allowed_list: [-1]
end
```

## Copyright and license

Copyright 2022 Zendesk

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the
License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.

## Author
Ben Osheroff <ben@gimbo.net>
