
#include <iostream>
#include <fstream>
#include <string>
#include <limits>
#include <vector>
#include <algorithm>

#include "Annealing.hpp"

using namespace std;

int main(int argc, char *argv[]) {
	
	//check args
    if(argc != 3) {
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
	string type, x, y;
	inputFile >> type;
	inputFile >> x;
	inputFile >> y;

	// set grid size
	Annealing annealing = Annealing(stoi(x), stoi(y));

	inputFile >> type;
	inputFile >> x;
	// set number of nodes
	annealing.set_num_nodes(stoi(x));

	while(!inputFile.eof()) {
		try {
			inputFile >> type;
			inputFile >> x;
			inputFile >> y;

			// read in edges
			annealing.add_edge(stoi(x), stoi(y));

		} catch(exception e) {

			cout << "Could not get edge info. Check input file\n" << e.what() << "\nExiting" << endl;
			return -1;
		}
	}

	annealing.solve();
	annealing.print_solution();
	annealing.save_to_file(outputFile);

    return 0;
}
