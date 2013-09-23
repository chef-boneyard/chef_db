-module(chef_sql_cookbook_deps).

-compile([export_all]).

-include_lib("eunit/include/eunit.hrl").
-include_lib("chef_db.hrl").
-include_lib("chef_objects/include/chef_types.hrl").

deps_retrieval() ->
    {foreachx,
     fun itest_cookbook_util:cookbook_setup/1,
     fun itest_cookbook_util:cookbook_cleanup/2,
     [{Spec, fun(_,_) ->
                     {Description,
                      fun() ->
                              {ok, Actual} = chef_sql:fetch_all_cookbook_version_dependencies(itest_util:the_org_id()),
                              ?assertEqual(Expected, Actual)
                      end}
             end}
      || {Description, Spec, Expected} <- [
                                           {"No Cookbooks!",
                                            [],
                                            []
                                           },

                                           {"One cookbook, no dependencies",
                                            [{<<"one">>, [
                                                          [{version, {1,0,0}}]
                                                         ]}],
                                            [{<<"cookbook_one">>, [{<<"1.0.0">>, []}]}]
                                           },

                                           {"Multiple cookbooks, one version each, no dependencies",
                                            [{<<"one">>, [
                                                          [{version, {1,0,0}}]
                                                         ]},
                                             {<<"two">>, [
                                                          [{version, {1,0,0}}]
                                                         ]},
                                             {<<"three">>, [
                                                            [{version, {1,0,0}}]
                                                           ]}
                                            ],
                                            [
                                             {<<"cookbook_two">>, [{<<"1.0.0">>, []}]},
                                             {<<"cookbook_three">>, [{<<"1.0.0">>, []}]},
                                             {<<"cookbook_one">>, [{<<"1.0.0">>, []}]}
                                            ]},

                                           {"Multiple cookbooks, multiple versions, no dependencies",
                                            [{<<"one">>, [
                                                          [{version, {1,0,0}}],
                                                          [{version, {2,0,0}}]
                                                         ]},
                                             {<<"two">>, [
                                                          [{version, {1,0,0}}],
                                                          [{version, {2,0,0}}]
                                                         ]},
                                             {<<"three">>, [
                                                            [{version, {1,0,0}}],
                                                            [{version, {2,0,0}}]
                                                           ]}
                                            ],
                                            [

                                             {<<"cookbook_two">>, [
                                                                   {<<"1.0.0">>, []},
                                                                   {<<"2.0.0">>, []}
                                                                  ]},
                                             {<<"cookbook_three">>, [
                                                                     {<<"1.0.0">>, []},
                                                                     {<<"2.0.0">>, []}
                                                                    ]},
                                             {<<"cookbook_one">>, [
                                                                   {<<"1.0.0">>, []},
                                                                   {<<"2.0.0">>, []}
                                                                  ]}
                                            ]
                                           },

                                           {"Multiple cookbooks, multiple versions, multiple dependencies",
                                            [
                                             {<<"one">>, [
                                                          [{version, {1,0,0}},
                                                           {dependencies, [
                                                                           {<<"foo">>, <<"= 1.0.0">>},
                                                                           {<<"bar">>, <<"> 2.0">>},
                                                                           {<<"baz">>, <<"> 3">>}
                                                                          ]}],
                                                          [{version, {2,0,0}},
                                                           {dependencies, [
                                                                           {<<"foo">>, <<"= 1.0.0">>},
                                                                           {<<"bar">>, <<"> 2.0">>},
                                                                           {<<"baz">>, <<"> 3">>}
                                                                          ]}
                                                          ]
                                                         ]},
                                             {<<"two">>, [
                                                          [{version, {1,0,0}},
                                                           {dependencies, [
                                                                           {<<"foo">>, <<"= 1.0.0">>},
                                                                           {<<"bar">>, <<"> 2.0">>},
                                                                           {<<"baz">>, <<"> 3">>}
                                                                          ]}],
                                                          [{version, {2,0,0}},
                                                           {dependencies, [
                                                                           {<<"foo">>, <<"= 1.0.0">>},
                                                                           {<<"bar">>, <<"> 2.0">>},
                                                                           {<<"baz">>, <<"> 3">>}
                                                                          ]}
                                                          ]
                                                         ]},
                                             {<<"three">>, [
                                                            [{version, {1,0,0}},
                                                             {dependencies, [
                                                                             {<<"foo">>, <<"= 1.0.0">>},
                                                                             {<<"bar">>, <<"> 2.0">>},
                                                                             {<<"baz">>, <<"> 3">>}
                                                                            ]}],
                                                            [{version, {2,0,0}},
                                                             {dependencies, [
                                                                             {<<"foo">>, <<"= 1.0.0">>},
                                                                             {<<"bar">>, <<"> 2.0">>},
                                                                             {<<"baz">>, <<"> 3">>}
                                                                            ]}
                                                            ]
                                                           ]}

                                            ],
                                            [
                                             {<<"cookbook_two">>, [
                                                                   {<<"1.0.0">>, [{<<"foo">>, <<"1.0.0">>, '='},
                                                                                  {<<"bar">>, <<"2.0">>, '>'},
                                                                                  {<<"baz">>, <<"3">>, '>'}]},
                                                                   {<<"2.0.0">>, [{<<"foo">>, <<"1.0.0">>, '='},
                                                                                  {<<"bar">>, <<"2.0">>, '>'},
                                                                                  {<<"baz">>, <<"3">>, '>'}]}
                                                                  ]},
                                             {<<"cookbook_three">>, [
                                                                     {<<"1.0.0">>, [{<<"foo">>, <<"1.0.0">>, '='},
                                                                                    {<<"bar">>, <<"2.0">>, '>'},
                                                                                    {<<"baz">>, <<"3">>, '>'}]},
                                                                     {<<"2.0.0">>, [{<<"foo">>, <<"1.0.0">>, '='},
                                                                                    {<<"bar">>, <<"2.0">>, '>'},
                                                                                    {<<"baz">>, <<"3">>, '>'}]}
                                                                    ]},
                                             {<<"cookbook_one">>, [{<<"1.0.0">>, [{<<"foo">>, <<"1.0.0">>, '='},
                                                                                  {<<"bar">>, <<"2.0">>, '>'},
                                                                                  {<<"baz">>, <<"3">>, '>'}]},
                                                                   {<<"2.0.0">>, [{<<"foo">>, <<"1.0.0">>, '='},
                                                                                  {<<"bar">>, <<"2.0">>, '>'},
                                                                                  {<<"baz">>, <<"3">>, '>'}]}
                                                                  ]}

                                            ]
                                           }
                                          ]
     ]
    }.
