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
    m_shortest_len = 1;

    int nodes_placed = 0;
    for (int y = 0; y < grid_size_y; y++) {
        for (int x = 0; x < grid_size_x; x++) {
            if (nodes_placed < m_num_nodes) {
                node n = node{nodes_placed, false, x, y};
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
    int longest = 0, shortest = INT32_MAX;
    for(edge* e : m_edges) {
        int e_cost = edge_length(m_nodes[e->node_1], m_nodes[e->node_2]);
        e->length = e_cost;
        sum += e_cost * e_cost;
        if (e_cost < shortest) {
            shortest = e_cost;
        }
        if (e_cost > longest) {
            m_longest_edge = e;
            longest = e_cost;
        }
        else if (e_cost <= m_shortest_len) {
            m_nodes[e->node_1].locked = true;
            m_nodes[e->node_2].locked = true;
        }
    }
    m_shortest_len = shortest;
    m_nodes[m_longest_edge->node_1].locked = false;
    m_nodes[m_longest_edge->node_2].locked = false;
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

void FloorPlan::adjust_floorplan(){
    int option, rand_id, rand_id_2, rand_x, rand_y;
    //generate a random number between 0 and 1 (2 options we can add more)
    option = rand() % 3;
    //if option 0 swap two nodes
    if (option == 0){
        do{
            rand_id = rand() % m_num_nodes;
            rand_id_2 = rand() % m_num_nodes;
        } while(rand_id == rand_id_2);
        if (m_nodes[rand_id].locked || m_nodes[rand_id_2].locked) {
            return;
        }
        int temp_x = m_nodes[rand_id].x;
        int temp_y = m_nodes[rand_id].y;
        m_nodes[rand_id].x = m_nodes[rand_id_2].x;
        m_nodes[rand_id].y = m_nodes[rand_id_2].y;
        m_nodes[rand_id_2].x = temp_x;
        m_nodes[rand_id_2].y = temp_y;
        m_grid[m_nodes[rand_id_2].x][m_nodes[rand_id_2].y] = rand_id_2;
        m_grid[m_nodes[rand_id].x][m_nodes[rand_id].y] = rand_id;
    }
    else if (option == 1){  // if option 1 then just move a node to a random open location in grid
        rand_id = rand() % m_num_nodes;
        int start_id = rand_id;
        while (m_nodes[rand_id].locked) {
            if(++rand_id == m_num_nodes) {
                rand_id = 0;
            }
            if (rand_id = start_id) {
                // all nodes locked
                return;
            }
        }

        do{
            rand_x = rand() % grid_size_x;
            rand_y = rand() % grid_size_y;
        } while(m_grid[rand_x][rand_y] >= 0);
        m_grid[m_nodes[rand_id].x][m_nodes[rand_id].y] = -1;
        m_nodes[rand_id].x = rand_x;
        m_nodes[rand_id].y = rand_y;
        m_grid[rand_x][rand_y] = m_nodes[rand_id].id;
    }
    else if (option ==2){  //place nodes with longest edge close to eachother
        node* n1 = &m_nodes[m_longest_edge->node_1];
        node* n2 = &m_nodes[m_longest_edge->node_2];
        // check for an open spot
        int x, y;
        int xx[] = { 0, 1,1,1,0,-1,-1,-1,2,2,2,1,0,-1,-2,-2,-2,-2,-2,-1,0,1,2,2};
        int yy[] = {-1,-1,0,1,1, 1, 0,-1,0,1,2,2,2,2,2,0,0,-1,-2,-2,-2,-2,-2,-1};
        for (int i = 0; i < 24; i++) {
            x = n2->x + xx[i];
            y = n2->y + yy[i];
            if (x < grid_size_x && x >= 0 && y < grid_size_y && y >= 0) {
                if (m_grid[x][y] < 0) { // place node here
                    m_grid[x][y] = n1->id;
                    m_grid[n1->x][n1->y] = -1;
                    n1->x = x;
                    n1->y = y;
                    break;
                } 
            }
        }
    }
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
    int best_score, new_score, i;
    i = 0;
    // initial floorplan and cost
    best_score = m_solution.cost();

    // initialize other solution 
    new_score = m_new_solution.cost();

    while(temperature > stop_threshold) {
        // generate new solution, maybe use 5 different types of moves to generate new solution
        m_new_solution.adjust_floorplan();
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
        i += 1;
    }
    best_score = m_solution.cost();
    m_solution.print_grid();
    std::cout << "Number of Iterations: " << i << std::endl;
    return best_score;
}

void Annealing::print_solution() {
    m_solution.print_solution();
}

void Annealing::save_to_file(std::ofstream& ofile) {

}


