#include <vector>
#include <fstream>

class FloorPlan {
	public:
		FloorPlan();
		FloorPlan(int grid_x, int grid_y, int num_nodes);
		void add_edge(int n1, int n2);
		int cost();
		void print_grid();
		void print_solution();

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
		int edge_length(node& n1, node& n2);
		int grid_size_x;
		int grid_size_y;
		int** m_grid;
		int m_num_nodes;
		std::vector<edge*> m_edges;
		std::vector<node> m_nodes;
};

class Annealing {
public:
	Annealing();
	Annealing(int grid_x, int grid_y, int num_nodes);
	void add_edge(int n1, int n2);
	int solve();
	void print_solution();
	void save_to_file(std::ofstream& ofile);

private:
	FloorPlan m_solution;
	double initial_temperature = 0.0;
	double t_ratio = 0.0;
	double stop_threshold = 0.0;
};