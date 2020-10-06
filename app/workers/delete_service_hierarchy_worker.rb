# frozen_string_literal: true

class DeleteServiceHierarchyWorker < DeleteObjectHierarchyWorker
  private

  alias service object
end
