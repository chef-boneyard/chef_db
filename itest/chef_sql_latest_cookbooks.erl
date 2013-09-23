-module(chef_sql_latest_cookbooks).

-compile([export_all]).

-include_lib("eunit/include/eunit.hrl").
-include_lib("chef_db.hrl").
-include_lib("chef_objects/include/chef_types.hrl").

latest_cookbooks() ->
    {foreachx,
     fun itest_cookbook_util:cookbook_setup/1,
     fun itest_cookbook_util:cookbook_cleanup/2,
     [{Specs, fun(_, _) ->
                      {Description,
                       fun() ->
                               {ok, Actual} =
                                   chef_sql:fetch_latest_cookbook_versions(itest_util:the_org_id(),
                                                                           all, NumVersions),
                               ?assertEqual(Expected, Actual)
                       end}
              end}
      || {Description, Specs, NumVersions, Expected} <- [

                                               %% The format of the following test data is:
                                               %% {Description,
                                               %%  Specs, % in format needed by cookbook_setup/1
                                               %%  NumVersions,
                                               %%  Expected}

                                               %% Ask for just the latest versions of cookbooks
                                               %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                                               {"Nothing in the database",
                                                [],
                                                1,
                                                []},

                                               {"Single cookbook, single version",
                                                [{<<"1">>, [[{version, {0,0,1}}]]}],
                                                1,
                                                [{<<"cookbook_1">>, <<"0.0.1">>}]},


                                               {"Multiple cookbooks, single version each",
                                                [
                                                 {<<"1">>, [[{version, {0,0,1}}]]},
                                                 {<<"2">>, [[{version, {0,1,0}}]]},
                                                 {<<"3">>, [[{version, {1,0,0}}]]}
                                                ],
                                                1,
                                               [{<<"cookbook_1">>, <<"0.0.1">>},
                                                {<<"cookbook_2">>, <<"0.1.0">>},
                                                {<<"cookbook_3">>, <<"1.0.0">>}]},

                                               {"Multiple cookbooks, 3 versions each",
                                                [
                                                 {<<"1">>, [
                                                            [{version, {1,0,0}}],
                                                            [{version, {1,0,5}}],
                                                            [{version, {2,0,0}}]
                                                           ]},
                                                 {<<"2">>, [
                                                            [{version, {0,0,1}}],
                                                            [{version, {0,0,2}}],
                                                            [{version, {0,5,0}}]
                                                           ]},
                                                 {<<"3">>, [
                                                            [{version, {6,0,0}}],
                                                            [{version, {7,0,5}}],
                                                            [{version, {7,5,0}}]
                                                           ]}
                                                ],
                                                1,
                                               [{<<"cookbook_1">>, <<"2.0.0">>},
                                                {<<"cookbook_2">>, <<"0.5.0">>},
                                                {<<"cookbook_3">>, <<"7.5.0">>}
                                               ]},

                                               %% Now, ask for multiple versions
                                               %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                                               {"Ask for more than one version, but less than total versions present",
                                                [
                                                 {<<"1">>, [
                                                            [{version, {1,0,0}}],
                                                            [{version, {1,0,5}}],
                                                            [{version, {2,0,0}}]
                                                           ]},
                                                 {<<"2">>, [
                                                            [{version, {0,0,1}}],
                                                            [{version, {0,0,2}}],
                                                            [{version, {0,5,0}}]
                                                           ]},
                                                 {<<"3">>, [
                                                            [{version, {6,0,0}}],
                                                            [{version, {7,0,5}}],
                                                            [{version, {7,5,0}}]
                                                           ]}
                                                ],
                                                2,
                                               [
                                                {<<"cookbook_1">>, <<"2.0.0">>},
                                                {<<"cookbook_1">>, <<"1.0.5">>},
                                                {<<"cookbook_2">>, <<"0.5.0">>},
                                                {<<"cookbook_2">>, <<"0.0.2">>},
                                                {<<"cookbook_3">>, <<"7.5.0">>},
                                                {<<"cookbook_3">>, <<"7.0.5">>}
                                               ]},

                                               {"Ask for more versions than exist in the database; should return all versions",
                                                [
                                                 {<<"1">>, [
                                                            [{version, {1,0,0}}],
                                                            [{version, {1,0,5}}],
                                                            [{version, {2,0,0}}]
                                                           ]},
                                                 {<<"2">>, [
                                                            [{version, {0,0,1}}],
                                                            [{version, {0,0,2}}],
                                                            [{version, {0,5,0}}]
                                                           ]},
                                                 {<<"3">>, [
                                                            [{version, {6,0,0}}],
                                                            [{version, {7,0,5}}],
                                                            [{version, {7,5,0}}]
                                                           ]}
                                                ],
                                                5,
                                                [
                                                 {<<"cookbook_1">>, <<"2.0.0">>},
                                                 {<<"cookbook_1">>, <<"1.0.5">>},
                                                 {<<"cookbook_1">>, <<"1.0.0">>},
                                                 {<<"cookbook_2">>, <<"0.5.0">>},
                                                 {<<"cookbook_2">>, <<"0.0.2">>},
                                                 {<<"cookbook_2">>, <<"0.0.1">>},
                                                 {<<"cookbook_3">>, <<"7.5.0">>},
                                                 {<<"cookbook_3">>, <<"7.0.5">>},
                                                 {<<"cookbook_3">>, <<"6.0.0">>}
                                                ]},

                                               {"Explicitly asking for 'all' versions should return all versions",
                                                [
                                                 {<<"1">>, [
                                                            [{version, {1,0,0}}],
                                                            [{version, {1,0,5}}],
                                                            [{version, {2,0,0}}]
                                                           ]},
                                                 {<<"2">>, [
                                                            [{version, {0,0,1}}],
                                                            [{version, {0,0,2}}],
                                                            [{version, {0,5,0}}]
                                                           ]},
                                                 {<<"3">>, [
                                                            [{version, {6,0,0}}],
                                                            [{version, {7,0,5}}],
                                                            [{version, {7,5,0}}]
                                                           ]}
                                                ],
                                                all,
                                                [
                                                 {<<"cookbook_1">>, <<"2.0.0">>},
                                                 {<<"cookbook_1">>, <<"1.0.5">>},
                                                 {<<"cookbook_1">>, <<"1.0.0">>},
                                                 {<<"cookbook_2">>, <<"0.5.0">>},
                                                 {<<"cookbook_2">>, <<"0.0.2">>},
                                                 {<<"cookbook_2">>, <<"0.0.1">>},
                                                 {<<"cookbook_3">>, <<"7.5.0">>},
                                                 {<<"cookbook_3">>, <<"7.0.5">>},
                                                 {<<"cookbook_3">>, <<"6.0.0">>}
                                                ]}
                                              ]]
    }.
