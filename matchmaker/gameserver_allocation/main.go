package main

// Allocate a gameserver from a fleet named ‘simple-game-server’, with GameServerAllocation 
// https://agones.dev/site/docs/guides/access-api/#allocate-a-gameserver-from-a-fleet-named-simple-game-server-with-gameserverallocation
// https://golangtutorial.dev/tips/http-post-json-go/

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"net/http"
)

func main() {
	httpposturl := "http://localhost:8001/apis/allocation.agones.dev/v1/namespaces/default/gameserverallocations"
	fmt.Printf("URL: %v", httpposturl)

	var jsonData = []byte(`{"apiVersion":"allocation.agones.dev/v1","kind":"GameServerAllocation","spec":{"required":{"matchLabels":{"agones.dev/fleet":"simple-game-server"}}}}`)

	request, error := http.NewRequest("POST", httpposturl, bytes.NewBuffer(jsonData))
	request.Header.Set("Content-Type", "application/json; charset=UTF-8")

	client := &http.Client{}
	response, error := client.Do(request)

	if error != nil {
		panic(error)
	}

	defer response.Body.Close()

	fmt.Printf("response Status:  %v", response.Status)
	fmt.Printf("response Headers: %v", response.Header)
	body, _ := ioutil.ReadAll(response.Body)
	fmt.Printf("response Body:   %v", string(body))

}