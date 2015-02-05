# ActiveRecord association inheritance

Makes the model inherit the specified attribute from a named association.

Supports ActiveRecord 3.2, 4.0, and 4.1

## Install

    gem install active_record_inherit_assoc

## Usage

    # parent_name - The Symbol name of the parent association.
    # options     - The Hash options to use:
    #               :attr - A Symbol or an Array of Symbol names of the attributes
    #                       that should be inherited from the parent association.
    #
    class Post < ActiveRecord::Base
      belongs_to :category
      inherits_from :category, :attr => :account
    end

## Copyright and license

Copyright 2015 Zendesk

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the
License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.

## Author
Ben Osheroff <ben@gimbo.net>
