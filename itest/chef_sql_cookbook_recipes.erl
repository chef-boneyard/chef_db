-module(chef_sql_cookbook_recipes).

-compile([export_all]).

-include_lib("eunit/include/eunit.hrl").
-include_lib("chef_db/include/chef_db.hrl").
-include_lib("chef_objects/include/chef_types.hrl").

test_all() ->
    [ test_one(Description, Specs) || {Description, Specs} <- cbv_specs() ].

test_one(Description, Specs) ->
    ct:pal("~s", [Description]),
    itest_cookbook_util:cookbook_setup(Specs),
    Expected = itest_cookbook_util:recipes_from_cookbook_specs(Specs),
    {ok, Actual} = chef_sql:fetch_latest_cookbook_recipes(itest_util:the_org_id()),
    ?assertEqual(Expected, Actual),
    itest_cookbook_util:cookbook_cleanup(a, a).

cbv_specs() ->
    [
     {"Nothing in the database",
      []},

     {"One cookbook, 3 recipes; all recipes returned",
      [{<<"one">>, [[{version, {1,0,0}},
                     {recipe_names, [<<"recipeOne">>,
                                     <<"recipeTwo">>,
                                     <<"recipeThree">>]}]]}]},

     {"Two cookbooks, one version each; all recipes returned",
      [{<<"one">>, [
                    [{version, {1,0,0}},
                     {recipe_names, [<<"recipeOne">>,
                                     <<"recipeTwo">>,
                                     <<"recipeThree">>]}]
                   ]},
       {<<"two">>, [
                    [{version, {1,5,0}},
                     {recipe_names, [<<"foo">>,
                                     <<"bar">>]}]
                   ]}
      ]},

     {"Two cookbooks, one with no recipes (pathological case)",
      [{<<"one">>, [
                    [{version, {1,0,0}}]
                   ]},
       {<<"two">>, [
                    [{version, {1,5,0}},
                     {recipe_names, [<<"foo">>,
                                     <<"bar">>]}
                    ]
                   ]}
      ]},

     {"Multiple versions of multiple cookbooks; only the latest are returned",
      [{<<"one">>, [
                    [{version, {1,0,0}},
                     {recipe_names, [<<"recipeOne">>,
                                     <<"recipeTwo">>,
                                     <<"recipeThree">>]}],
                    [{version, {1,6,1}},
                     {recipe_names, [<<"webserver">>,
                                     <<"database">>]}],
                    [{version, {1,5,0}},
                     {recipe_names, [<<"spaghetti_carbonara">>,
                                     <<"chicken_saltimbocca">>,
                                     <<"boeuf_bourgignone">>]}]
                   ]},
       {<<"two">>, [
                    [{version, {1,5,0}},
                     {recipe_names, [<<"foo">>,
                                     <<"bar">>]}],
                    [{version, {0,0,1}},
                     {recipe_names, [<<"mongodb">>,
                                     <<"devnulldb">>,
                                     <<"webscale_utils">>]}]
                   ]}
      ]}
    ].
