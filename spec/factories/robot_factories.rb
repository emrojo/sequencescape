# frozen_string_literal: true

FactoryBot.define do
  factory :robot do
    name      { 'myrobot' }
    location  { 'lab' }
    transient do
      number_of_sources { 0 }
      number_of_destinations { 0 }
      number_of_controls { 0 }
    end

    after(:create) do |robot, evaluator|
      evaluator.number_of_sources.times do |i|
        robot.robot_properties << create(:robot_property, name: "Source #{i + 1}", key: "SCRC#{i + 1}", value: "#{i + 1}")
      end

      evaluator.number_of_destinations.times do |i|
        robot.robot_properties << create(:robot_property, name: "Destination #{i + 1}", key: "DEST#{i + 1}", value: "#{i + 1}")
      end

      evaluator.number_of_controls.times do |i|
        robot.robot_properties << create(:robot_property, name: "Control #{i + 1}", key: "CTRL#{i + 1}", value: "#{i + 1}")
      end
    end

    factory :robot_with_verification_behaviour do
      transient do
        verification_behaviour_value { 'SourceDestBeds' }
      end
      robot_properties { build_list :validation_property, 1, value: verification_behaviour_value }
    end

    factory :robot_with_generation_behaviour do
      transient do
        generation_behaviour_value { 'Tecan' }
      end
      robot_properties { build_list :generation_property, 1, value: generation_behaviour_value }
    end
  end

  factory :robot_property do
    name      { 'myrobot' }
    value     { 'lab' }
    key       { 'key_robot' }

    factory :validation_property do
      name  { 'Verification behaviour' }
      value { 'SourceDestBeds' }
      key   { 'verification_behaviour' }
    end

    factory :generation_property do
      name  { 'Generation behaviour' }
      value { 'Tecan' }
      key   { 'generation_behaviour' }
    end
  end
end
