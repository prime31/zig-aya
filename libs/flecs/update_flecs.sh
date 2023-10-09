echo "flecs updater got arg: $1"
cd "$1"
pwd
cd lib

echo "----- download flecs.h and flecs.c"
curl -O https://raw.githubusercontent.com/SanderMertens/flecs/master/flecs.h
curl -O https://raw.githubusercontent.com/SanderMertens/flecs/master/flecs.c

echo "----- translate-c the new flecs.h file"
zig translate-c flecs.h > ../../../src/ecs/flecs/flecs.zig

echo "----- done"