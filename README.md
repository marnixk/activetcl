# Tcl Mysql Database helper functions

This module contains some helpful functionality that will help you setup and manage simple database structures easily like you would with the likes of ActiveRecord. 

#### Creating models

Creating a model is as simple as defining a namespace and called `table`. Like so:

    namespace eval Company {
        table "companies"
    }

Then, if you want to define relations this table has with other tables, do the following:

    namespace eval Category {
        table "categories"
        has games {Game category_id}
    }

There, a category has one or more games, which is mapped to the Game model using the "category_id" field in the target table. 

Sometimes you will want to indicate that this record is owned by another model, you can do that by specifying `belongs-to`.

    namespace eval Rating {
        table "ratings"
        belongs-to game game_id {Game id}
    }

.. where "game" is the name of the association, `game_id` is the field in the current table that is mapped to the `Game` model through the `id` field.

#### Retrieving results

When a table is defined, the namespace automatically gets two methods, `find` and `all`. To retrieve one result by a specific ID in our Company model call: 

    set selected_company [Company::find {:id 10}]

This will query one record that has that identifier as its primary key, which will be returned as a list that could be fed into `array set` with the column names prefixing the values.

To retrieve all companies, call: 

    set all_companies [Company::all]

Easy enough!

Information from associations are never loaded up front, to get that information one has to unfold the result, and specify which associations should be loaded. In our `Rating` example, we have a `game` association. Let's load it like this:

    set rating [Rating::find {:id 1}]
    set unfolded_rating [db'unfold {game} $rating]

You will now get returned an array with the original row in the `row` key, and all the requested associations (you can specify more than one) in their equally named keys. 

#### Named queries

Named queries are an easy way to encapsulate an often executed query in a name. To create a named query, in your model's namespace, put the following:

        named-query name-of-query {argument-list} {
            # build your query here and return it
        } 

A concrete example of this would be a game that gets all the games that are marked as "hot" and order them in descending order of updates. 

        named-query hot-games {{top 5}} {
            return [select Game {
                    where { {is_hot_game 1} }
                    order "updated_at DESC"
                    limit $top
                }]
        }

As you can see there's a simple SELECT-query builder that uses variable substitutions. After having specified a named query, to procs are added to the namespace, one called `hot-games` and one called `find-hot-games`. To find the top 10 of hot games call the following method:

    set games [Game::find-hot-games 10]

.. or to get the default parameter's value of 5 games call:

    set games [Game::find-hot-games]

#### Example

Below you can see a more complete example of a `games` table that belongs to a category, a company, and has one or more ratings. Then, it also has a number of named, parameterized queries that yield one or more results.

    namespace eval Game {
        table "games"
        belongs-to category category_id {Category id}
        belongs-to company company_id {Company id}
        has ratings {Rating game_id}

        named-query latest-games {{top 5}} {
            return [select Game {
                    order "updated_at DESC"
                    limit $top
                }]
        }

        named-query hot-games {{top 5}} {
            return [select Game {
                    where { {is_hot_game 1} }
                    order "updated_at DESC"
                    limit $top
                }]
        }

    }

    set game [Game::find 1]
    set complete_game [db'unfold {category company ratings} $game]

    # to change a value
    array set arr_game $game
    set game(name) "New name"
    db'save Game [array get game]

    # delete a game
    db'delete Game [array get game]

    # delete a game
    db'delete Game {id 10}