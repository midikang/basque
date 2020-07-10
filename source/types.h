#include "configuration.h"
#include "utilities.h"
#include <SDL2/SDL_mixer.h>
#include <SDL2/SDL_ttf.h>
#include <stdbool.h>

typedef struct {
    SDL_Renderer* renderer;
    SDL_Window* window;
} App;

typedef struct {
    int x;
    int y;
} Axes;

typedef struct {
    float x;
    float y;
} Precise_Axes;

enum directions {
    NORTH = 0,
    EAST,
    SOUTH,
    WEST
};

typedef struct {
    int north;
    int east;
    int south;
    int west;
} Directions;

typedef struct {
    int north[2];
    int east[2];
    int south[2];
    int west[2];
} Direction_Bounds;

typedef struct {
    Axes window;
    Axes global;
    Directions can_move;

    Direction_Bounds bounds;

    int direction;
} Player;

typedef struct {
    Axes clip;

    // This goes North, East, South, and West
    // (in increasing order by degree).
    Directions border;
} Tile_Data;

typedef struct {
    int rows;
    int columns;
    int* columns_in_row;

    int** layout;
    char* layout_file_base;
    char* layout_file;
    time_t layout_modified_time;
    char* layout_string;
    size_t layout_string_length;

    char* attributes_file;
    time_t attributes_modified_time;
    char* attributes_string;
    size_t attributes_string_length;
    Tile_Data tile_attributes[TILE_ATTRIBUTES_LIMIT];

    int total_parsed_attributes;
} Map;

typedef struct {
    SDL_Surface text_surfaces[TILE_ATTRIBUTES_LIMIT];
    SDL_Texture* text_textures[TILE_ATTRIBUTES_LIMIT];
    int layout_file_suffix;
    int selected_tile;
} Editor;

typedef struct {
    Axes scroll;

    SDL_bool done;

    Player player;

    SDL_Texture* player_image;
    SDL_Texture* background_image;

    Map map;

    Mix_Music* music;

    TTF_Font* font;
    TTF_Font* font_outline;

    bool EDIT_MODE;

    Editor editor;
} GameState;
