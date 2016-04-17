class Import
  include Mongoid::Document

  scope :errored, lambda { where(state: "Errored") }
  scope :completed, lambda { where(state: "Completed") }
  scope :warnings, lambda { where(state: "Warnings") }
  scope :running, lambda { where(state: "Running") }

  field :revision, type: Integer, default: lambda { self.class.next_revision }
  field :options, type: String
  field :source,   type: String
  field :changeset, type: Hash
  field :started_at, type: Time, default: lambda { Time.now }
  field :completed_at, type: Time
  field :state, type: String, default: 'Running'
  field :messages, type: Array, default: []
  field :error
  field :block, type: Boolean, default: true

  index(started_at: -1)

  before_create :mark_others_as_killed

  def self.current_revision
    max(:revision).to_i
  end

  def completed!
    reload
    if messages.empty?
      update_attributes(completed_at: Time.now, state: "Completed")
    else
      update_attributes(completed_at: Time.now, state: "Warnings")
    end
  end

  def errored!(error)
    update_attributes(
      completed_at: Time.now,
      error: {message: error.to_s, details: error.backtrace},
      state: 'Errored'
    )
  end

  def add_message(message, detail)
    if messages.count < 100
      messages << {message: message, detail: detail}
    end
  end

  def self.next_revision
    max = current_revision
    max ? max + 1 : 0
  end

  def mark_others_as_killed
    Import.where(:state.in => ['Running', nil]).update_all(state: 'Killed')
  end
end
