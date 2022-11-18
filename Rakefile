# frozen_string_literal: true

require "bundler/gem_tasks"

task(:sord) do 
  system("sord sig/modrinth.rbs --rbs --no-regenerate --replace-errors-with-untyped --no-sord-comments")
end

task(:undoc) do
  system('yard stats --list-undoc')
end

task default: %i[sord]
