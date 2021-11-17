// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"math/rand"

	//"github.com/golang/protobuf/ptypes"
	//"github.com/golang/protobuf/ptypes/any"
	//"github.com/golang/protobuf/ptypes/wrappers"

	"open-match.dev/open-match/pkg/pb"
)

// Ticket generates a Ticket with a mode search field that has one of the
// randomly selected modes.
func makeTicket() *pb.Ticket {

	/* // Used with Extensions
	v := &wrappers.DoubleValue{Value: 123}
	a, _ := ptypes.MarshalAny(v)
	*/

	ticket := &pb.Ticket{
		SearchFields: &pb.SearchFields{
			// https://open-match.dev/site/docs/reference/api/#searchfields
			Tags: []string{
				gameMode(),
			},
			StringArgs: map[string]string{
				"attributes.region": region(),
			},
			DoubleArgs: map[string]float64{
				"skill": get_skill(),
			},

		},

		/*
		Extensions: map[string]*any.Any{
				"score": a,
		},
		*/
	}

	return ticket
}

func gameMode() string {
	modes := []string{"mode.creative", "mode.ctf", "mode.battleroyale"}
	return modes[rand.Intn(len(modes))]
}

func region() string {
	regions := []string{"us", "europe", "asia"}
	return regions[rand.Intn(len(regions))]
}

func get_skill() float64 {
	skill := 1200 + (rand.Intn(500) - rand.Intn(500))
	return float64(skill)
}