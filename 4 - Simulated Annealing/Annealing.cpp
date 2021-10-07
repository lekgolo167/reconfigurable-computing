#include "Annealing.hpp"
#include <iostream>
#include <algorithm>
#include <cmath>

FloorPlan::FloorPlan() {

}

FloorPlan::FloorPlan(int grid_x, int grid_y, int num_nodes) {
    m_grid = new int* [grid_y];
    for(int i = 0; i < grid_y; i++) {
        m_grid[i] = new int[grid_x];
    }

    grid_size_x = grid_x;
    grid_size_y = grid_y;
    m_num_nodes = num_nodes;

    int nodes_placed = 0;
    for (int y = 0; y < grid_size_y; y++) {
        for (int x = 0; x < grid_size_x; x++) {
            if (nodes_placed < m_num_nodes) {
                node n = node{nodes_placed, x, y};
                m_nodes.push_back(n);
                m_grid[x][y] = n.id;
            }
            else {
                m_grid[x][y] = -1;
            }
            nodes_placed++;
        }
    }
}

void FloorPlan::copy(FloorPlan& other) {
    for (int y = 0; y < grid_size_y; y++) {
        for (int x = 0; x < grid_size_x; x++) {
            int id = other.m_grid[x][y];
            m_grid[x][y] = id;
            if (id >= 0) {
                m_nodes[id].x = x;
                m_nodes[id].y = y;
            }
        }
    }
}

void FloorPlan::add_edge(int n1, int n2) {
    m_edges.push_back(new edge{0, n1, n2});
}

int FloorPlan::edge_length(node& n1, node& n2) {
    return std::abs(n1.x - n2.x) + std::abs(n1.y - n2.y);
}

int FloorPlan::cost() {
    int sum = 0;
    for(edge* e : m_edges) {
        int e_cost = edge_length(m_nodes[e->node_1], m_nodes[e->node_2]);
        e->length = e_cost;
        sum += e_cost * e_cost;
    }
    return sum;
}

void FloorPlan::print_grid() {
    for (int y = 0; y < grid_size_y; y++) {
        for (int x = 0; x < grid_size_x; x++) {
            if (m_grid[x][y] >= 0) {
                std::cout << "| " << m_grid[x][y] << " |";
            }
            else {
                std::cout << "| - |";
            }
        }
        std::cout << std::endl;
    }
}

void FloorPlan::print_solution() {
    for (node n : m_nodes) {
        std::cout << "Node " << n.id << " placed at (" << n.x << "," << n.y << ")\n";
    }
    for (edge* e : m_edges) {
        std::cout << "Edge from " << e->node_1 << " to " << e->node_2 << " has length " << e->length << "\n";
    }
    std::cout << std::endl;
}

Annealing::Annealing() {

}

Annealing::Annealing(int grid_x, int grid_y, int num_nodes) {
    m_solution = FloorPlan(grid_x, grid_y, num_nodes);
    m_new_solution = FloorPlan(grid_x, grid_y, num_nodes);
    srand(time(NULL));
}

void Annealing::add_edge(int n1, int n2) {
    m_solution.add_edge(n1, n2);
    m_new_solution.add_edge(n1, n2);
}


int Annealing::solve() {
    double temperature = initial_temperature;
    int best_score, new_score;

    // initial floorplan and cost
    best_score = m_solution.cost();

    while(temperature > stop_threshold) {
        // generate new solution, maybe use 5 different types of moves to generate new solution

        // score solution
        new_score = m_new_solution.cost();

        // if new better than old
        if (new_score < best_score) {
            // copy new solution to best solution
            m_solution.copy(m_new_solution);
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
                // copy new solution to best solution
                m_solution.copy(m_new_solution);
            }
            else {
                m_new_solution.copy(m_solution);
            }
            
        }
        temperature *= t_ratio;
    }

    m_solution.print_grid();
    return best_score;
}

void Annealing::print_solution() {

}

void Annealing::save_to_file(std::ofstream& ofile) {

}
