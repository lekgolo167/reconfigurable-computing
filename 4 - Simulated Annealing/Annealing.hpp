#include <vector>
#include <fstream>

class Annealing {
public:
	Annealing();
	Annealing(int grid_x, int grid_y);
	void set_grid_size(int grid_x, int grid_y);
	void set_num_nodes(int num);
	void add_edge(int n1, int n2);
	int solve();
	void print_grid(int** grid);
	void print_solution();
	void save_to_file(std::ofstream& ofile);

private:
	struct edge {
		int length;
		int node_1;
		int node_2;
	};
	struct node {
		int id;
		int x;
		int y;
	};
	int cost(std::vector<node>& nodes);
	int edge_length(node& n1, node& n2);
	int grid_size_x;
	int grid_size_y;
	int num_nodes;
	double initial_temperature = 0.0;
	double t_ratio = 0.0;
	double stop_threshold = 0.0;
	int** best_grid;
	int** tmp_grid;
	std::vector<edge*> edges;
	std::vector<node> best_nodes;
	std::vector<node> tmp_nodes;
};