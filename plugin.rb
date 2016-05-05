# name: discourse-spark-plug
# about: Process incoming webhook events
# version: 0.1
# authors: Erick Guan (fantasticfears@gmail.com)

PLUGIN_NAME = 'discourse_spark_plug'.freeze
SETTING_NAME = 'spark_plug'.freeze

enabled_site_setting :spark_plug_enabled

after_initialize do
  module ::DiscourseSparkPlug
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseSparkPlug
    end
  end

  DiscourseSparkPlug::Engine.routes.draw do
    post '/ignition' => 'ignition#trigger'
  end

  Discourse::Application.routes.append do
    mount ::DiscourseSparkPlug::Engine, at: "/spark-plug"
  end

  class DiscourseSparkPlug::IgnitionController < ::ApplicationController
    requires_plugin PLUGIN_NAME
    skip_before_action :verify_authenticity_token, only: [:trigger]

    def trigger
      Rails.logger.debug request
      render :nothing, status: 200
    end
  end
end
