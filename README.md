# ActiveRecord association inheritance

Makes the model inherit the specified attribute from a named association.

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


## Copyright

Copyright (c) 2011 Zendesk. See MIT-LICENSE for details.

## Author
Ben Osheroff <ben@gimbo.net>
