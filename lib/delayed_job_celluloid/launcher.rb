#
#Copyright 2013 Neighbor Market
#
#This file is part of Neighbor Market.
#
#Neighbor Market is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Neighbor Market is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Neighbor Market.  If not, see <http://www.gnu.org/licenses/>.
#

require_relative 'manager'

module DelayedJobCelluloid
  class Launcher
    attr_reader :manager, :options
    def initialize(options, worker_count)
      @options = options
      @manager = Manager.new(options, worker_count)
    end

    def run
      manager.async.start
    end

    def stop
      manager.async.stop
      manager.wait(:shutdown)
    end
  end
end