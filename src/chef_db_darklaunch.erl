%% -*- erlang-indent-level: 4;indent-tabs-mode: nil; fill-column: 92-*-
%% Copyright 2012 Opscode, Inc. All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
-module(chef_db_darklaunch).

-export([is_enabled/2]).

-include_lib("eunit/include/eunit.hrl").

%% The darklaunch module used by chef_db can be set using this
%% define. The default included here ignores `OrgName' and answers
%% use_couchdb to all couchdb_* features.  That value is set
%% in opscode-omnibus/opscode-omnibus/files/private-chef-cookbooks/
%% private-chef/templates/default/oc_erchef_config.erb
-ifndef(CHEF_DB_DARKLAUNCH).
is_enabled(<<"couchdb_", _Rest/binary>>, _) ->
  envy:get('opscode-erchef', use_couchdb, boolean);
is_enabled(_, _) ->
  ~envy:get(chef_db, use_couchdb, boolean);
-else.
is_enabled(Feature, Darklaunch) ->
    ?CHEF_DB_DARKLAUNCH:is_enabled(Feature, Darklaunch).
-endif.




