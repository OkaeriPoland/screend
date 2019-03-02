package main

import (
	"github.com/pkg/errors"
	"strconv"
	"strings"
)

type Screen struct {
	id   int
	name string
}

func runScreen(screenName string, command string) (Screen, error) {

	exists, err := doesScreenExists(screenName)
	if err != nil {
		return Screen{}, err
	}

	if exists {
		return Screen{}, errors.New("SCREEN_ALREADY_EXISTS")
	}

	args := []string{"screen", "-dmS", screenName}
	args = append(args, strings.Split(command, " ")...)

	_, err = executeCommand(args...)
	if err != nil {
		if err.Error() == "exit status 1" {
			return Screen{}, errors.New("exit status 1: check command")
		}
		return Screen{}, err
	}

	screen, err := getScreenByName(screenName)
	if err != nil {
		if err.Error() == "SCREEN_NOT_FOUND" {
			return Screen{}, errors.New("Screen " + screenName + " not present after creation")
		}
		return Screen{}, err
	}

	return screen, nil
}

func getRunningScreens() ([]Screen, error) {

	output, err := executeCommand("screen", "-ls")
	if err != nil {
		if !strings.HasPrefix(output, "No Sockets found in") {
			return []Screen{}, err
		}
		return []Screen{}, nil
	}

	var screens []Screen
	lines := strings.Split(output, "\n")
	for _, line := range lines {

		if !strings.HasPrefix(line, "\t") {
			continue
		}

		lineParts := strings.Split(line, "\t")
		fullScreenName := lineParts[1]
		fullNameParts := strings.Split(fullScreenName, ".")

		name := strings.Join(fullNameParts[1:], ".")
		id, err := strconv.Atoi(fullNameParts[0])
		if err != nil {
			return []Screen{}, err
		}

		screens = append(screens, Screen{id, name})
	}

	return screens, nil
}

func doesScreenExists(screenName string) (bool, error) {

	_, err := getScreenByName(screenName)
	if err != nil {
		if err.Error() == "SCREEN_NOT_FOUND" {
			return false, nil
		}
		return false, err
	}

	return true, nil
}

func getScreenByName(screenName string) (Screen, error) {

	screens, err := getRunningScreens()
	if err != nil {
		return Screen{}, err
	}

	for _, screen := range screens {
		if screen.name != screenName {
			continue
		}
		return screen, nil
	}

	return Screen{}, errors.New("SCREEN_NOT_FOUND")
}
