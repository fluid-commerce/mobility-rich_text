# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

# Load Rails dependencies needed for ActionText
require "active_support/all"
require "active_model"
require "action_text"

# Define the ContentHelper that ActionText::Content needs
# This is normally provided by the Rails engine but we need it for standalone testing
module ActionText
  module ContentHelper
    def render_action_text_content(content, &)
      content.to_html
    end
  end
end

# Now load ActionText::Content
require "action_text/content"

require "mobility/rich_text"

require "minitest/autorun"
