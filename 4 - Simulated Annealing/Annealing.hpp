#include <vector>
#include <fstream>

class FloorPlan {
	public:
		FloorPlan();
		FloorPlan(int grid_x, int grid_y, int num_nodes);
		void add_edge(int n1, int n2);
		int cost();
		void copy(FloorPlan& other);
		void print_grid();
		void print_solution();
		void adjust_floorplan();
		int grid_size_x;
		int grid_size_y;
		int m_num_nodes;
		int** m_grid;

	private:
		struct edge {
			int length;
			int node_1;
			int node_2;
		};
		struct node {
			int id;
			bool locked;
			int x;
			int y;
		};
		int edge_length(node& n1, node& n2);
		std::vector<edge*> m_edges;
		std::vector<node> m_nodes;
		edge* m_longest_edge;
		int m_shortest_len;
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
	FloorPlan m_new_solution;
	double initial_temperature = 100000000;
	double t_ratio = .9999;
	double stop_threshold = 0.1;
};