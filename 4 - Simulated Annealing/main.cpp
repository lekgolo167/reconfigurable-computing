
#include <iostream>
#include <fstream>
#include <string>
#include <limits>
#include <chrono>

#include "Annealing.hpp"

using namespace std;

int main(int argc, char *argv[]) {
	
	//check args
    if(argc <= 2) {
        cout << "Need 2 filenames for input and output from the commandline\nExiting..." << endl;
        return -1;
    }
	
	//get file names
    char* inputFileName = argv[1];
    char* outputFileName = argv[2];
    ifstream inputFile(inputFileName);
    ofstream outputFile(outputFileName);
    
	//check ifile.
    if(!inputFile.good()) {
        cout << "Input file does not exist\nExiting..." << endl;
        return -1;
    }

	//read lines of ifile
	string type, x, y, z;
	inputFile >> type;
	inputFile >> x;
	inputFile >> y;


	inputFile >> type;
	inputFile >> z;

	// set grid size and number of nodes
	Annealing annealing = Annealing(stoi(x), stoi(y), stoi(z));
	if(argc == 6){
		annealing.set_temperatures(atof(argv[3]), atof(argv[4]), atof(argv[5]));
	}
	while(!inputFile.eof()) {
		try {
			inputFile >> type;
			if (type == "")
				continue;
			inputFile >> x;
			inputFile >> y;

			// read in edges
			annealing.add_edge(stoi(x), stoi(y));
			type = "";

		} catch(exception e) {

			cout << "Could not get edge info. Check input file\n" << e.what() << "\nExiting" << endl;
			return -1;
		}
	}

	if (argc == 6) {
		std::chrono::time_point<std::chrono::high_resolution_clock> start = std::chrono::high_resolution_clock::now();
		int cost = annealing.solve(true);
		std::chrono::time_point<std::chrono::high_resolution_clock> end = std::chrono::high_resolution_clock::now();
        std::chrono::duration<long, std::nano> time = end - start;

		cout << cost << endl;
		outputFile << cost << "\n";
		outputFile << time.count() / 1000;

		annealing.print_solution(cout);
	}
	else {
		annealing.solve(false);
		annealing.print_solution(outputFile);
	}

	outputFile.close();

    return 0;
}
