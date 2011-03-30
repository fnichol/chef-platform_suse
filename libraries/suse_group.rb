#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
# Copyright:: Copyright (c) 2011 Fletcher Nichol
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider/group/groupadd'
require 'chef/mixin/shell_out'
require 'chef/platform'

class Chef
  class Provider
    class Group
      class Suse < Chef::Provider::Group::Groupadd

        include Chef::Mixin::ShellOut

        def load_current_resource
          super

          raise Chef::Exceptions::Group, "Could not find binary /usr/sbin/groupmod for #{@new_resource}" unless ::File.exists?("/usr/sbin/groupmod")
        end

        def modify_group_members
          unless @new_resource.members.empty?
            if(@new_resource.append)
              @new_resource.members.each do |member|
                Chef::Log.debug("#{@new_resource}: appending member #{member} to group #{@new_resource.group_name}")
                shell_out!("groupmod -A #{member} #{@new_resource.group_name}")
              end
            else
              raise Chef::Exceptions::Group, "setting group members directly is not supported by #{self.to_s}"
            end
          else
            Chef::Log.debug("#{@new_resource}: not changing group members, the group has no members")
          end
        end
      end
    end
  end
end

Chef::Platform.set :platform => :suse, :resource => :group, :provider => Chef::Provider::Group::Suse
