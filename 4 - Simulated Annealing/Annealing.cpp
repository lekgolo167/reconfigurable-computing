#include "Annealing.hpp"
#include <iostream>

Annealing::Annealing() {

}

Annealing::Annealing(int grid_x, int grid_y) {
    grid = new node** [grid_x];
    for(int i = 0; i < grid_x; i++) {
        grid[i] = new node*[grid_y];
    }
    grid_size_x = grid_x;
    grid_size_y = grid_y;
}

void Annealing::set_num_nodes(int num) {
    int nodes_placed = 0;
    for (int x = 0; x < grid_size_x; x++) {
        for (int y = 0; y < grid_size_y; y++) {
            if (nodes_placed < num) {
                node* n = new node{nodes_placed, x, y};
                nodes.push_back(*n);
                grid[x][y] = n;
            }
            else {
                grid[x][y] = nullptr;
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

int Annealing::cost() {
    int sum = 0;
    for(edge* e : edges) {
        int e_cost = edge_length(nodes[e->node_1], nodes[e->node_2]);
        e->length = e_cost;
        sum += e_cost * e_cost;
    }
    return sum;
}

int Annealing::solve() {
    return cost();
}

void Annealing::print_grid() {
    for (int x = 0; x < grid_size_x; x++) {
        for (int y = 0; y < grid_size_y; y++) {
            if (grid[x][y]) {
                std::cout << "| " << grid[x][y]->id << " |";
            }
            else {
                std::cout << "| - |";
            }
        }
        std::cout << std::endl;
    }
}

void Annealing::print_solution() {
    for (node n : nodes) {
        std::cout << "Node " << n.id << " placed at (" << n.x << "," << n.y << ")\n";
    }
    for (edge* e : edges) {
        std::cout << "Edge from " << e->node_1 << " to " << e->node_2 << " has length " << e->length << "\n";
    }
    std::cout << std::endl;
}

void Annealing::save_to_file(std::ofstream& ofile) {

}
