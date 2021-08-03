docker rmi -f game-event-simulator-test
docker build -t game-event-simulator-test .

# Run container for 5 seconds
echo "Running container to test it out..."
docker run -it game-event-simulator-test

# Cleanup
docker rmi -f game-event-simulator-test
