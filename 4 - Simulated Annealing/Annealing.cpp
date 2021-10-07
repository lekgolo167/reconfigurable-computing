#include "Annealing.hpp"
#include <iostream>
#include <algorithm>
#include <cmath>

Annealing::Annealing() {

}

Annealing::Annealing(int grid_x, int grid_y) {
    best_grid = new int* [grid_x];
    tmp_grid = new int* [grid_x];
    for(int i = 0; i < grid_x; i++) {
        best_grid[i] = new int[grid_y];
        tmp_grid[i] = new int[grid_y];
    }
    grid_size_x = grid_x;
    grid_size_y = grid_y;

    srand(time(NULL));
}

void Annealing::set_num_nodes(int num) {
    int nodes_placed = 0;
    for (int x = 0; x < grid_size_x; x++) {
        for (int y = 0; y < grid_size_y; y++) {
            if (nodes_placed < num) {
                node n = node{nodes_placed, x, y};
                best_nodes.push_back(n);
                tmp_nodes.push_back(n);
                best_grid[x][y] = n.id;
                tmp_grid[x][y] = n.id;
            }
            else {
                best_grid[x][y] = -1;
                tmp_grid[x][y] = -1;
            }
            nodes_placed++;
        }
    }
}

void Annealing::add_edge(int n1, int n2) {
    edges.push_back(new edge{0, n1, n2});
}

int Annealing::edge_length(node& n1, node& n2) {
    return std::abs(n1.x - n2.x) + std::abs(n1.y - n2.y);
}

int Annealing::cost(std::vector<node>& nodes) {
    int sum = 0;
    for(edge* e : edges) {
        int e_cost = edge_length(nodes[e->node_1], nodes[e->node_2]);
        e->length = e_cost;
        sum += e_cost * e_cost;
    }
    return sum;
}

int Annealing::solve() {
    double temperature = initial_temperature;
    int best_score, new_score;

    // initial floorplan and cost
    best_score = cost(best_nodes);

    while(temperature > stop_threshold) {
        // generate new solution, maybe use 5 different types of moves to generate new solution

        // score solution
        new_score = cost(tmp_nodes);

        // if new better than old
        if (new_score < best_score) {
            // copy new grid to best grid

            best_score = new_score;
        }
        else {
            // compute deltaE
            int delta_E = std::abs(best_score - new_score);
            // compute acceptance probablility
            double p = std::exp(-delta_E / temperature);
            // generate random probablility (r)
            double r = (rand() % 100) / 100;

            if (r <= p) {
                // copy new grid to best grid
            }
            
        }
        temperature *= t_ratio;
    }
    print_grid(best_grid);
    return best_score;
}

void Annealing::print_grid(int** grid) {
    for (int x = 0; x < grid_size_x; x++) {
        for (int y = 0; y < grid_size_y; y++) {
            if (grid[x][y] >= 0) {
                std::cout << "| " << grid[x][y] << " |";
            }
            else {
                std::cout << "| - |";
            }
        }
        std::cout << std::endl;
    }
}

void Annealing::print_solution() {
    for (node n : best_nodes) {
        std::cout << "Node " << n.id << " placed at (" << n.x << "," << n.y << ")\n";
    }
    for (edge* e : edges) {
        std::cout << "Edge from " << e->node_1 << " to " << e->node_2 << " has length " << e->length << "\n";
    }
    std::cout << std::endl;
}

void Annealing::save_to_file(std::ofstream& ofile) {

}
