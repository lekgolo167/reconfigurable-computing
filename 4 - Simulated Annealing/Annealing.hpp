#include <vector>
#include <fstream>

class Annealing {
public:
	Annealing();
	Annealing(int grid_x, int grid_y);
	void set_grid_size(int grid_x, int grid_y);
	void set_num_nodes(int num);
	void add_edge(int n1, int n2);
	void solve();
	void print_solution();
	void save_to_file(std::ofstream& ofile);

private:
	int grid_size_x;
	int grid_size_y;
	int num_nodes;
	struct edge {
		int node_1;
		int node_2;
	};
	std::vector<edge> edges;
};