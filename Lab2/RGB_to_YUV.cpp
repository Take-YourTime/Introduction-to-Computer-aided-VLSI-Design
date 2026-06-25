// To understand this program logic, read Report.pdf first.
// This program is an edited form of DFG_scheduling.cpp, you should read DFG_scheduling.cpp befroe reading this program.

#include <iostream>
#include <cstdlib>
#include <fstream>
#include <vector>
#include <algorithm>
#include <iomanip>
#include <utility>
#include <string>
#include <map>

using namespace std;

const string FILE_NAME = "RGB_to_YUV.txt";

class Operation {
public:
    int op; // 1: add, 2: mul, 3: sub
    string node1;
    string node2;
    string result;
    int level = 1;

    Operation() = default;

    Operation(int o, string n1, string n2, string r) {
        op = o;
        node1 = n1;
        node2 = n2;
        result = r;
    }
};

vector<Operation> listOp;

bool isAvailable(const map<string, int>& producer, const string& node) {
    return producer.find(node) == producer.end();
}

// build critical path priority
void DFS(const map<string, int>& producer, const string& node, int level) {
    auto it = producer.find(node);

    // no producer => outside input or already available
    if (it == producer.end()) return;

    int opIndex = it->second;

    if (listOp[opIndex].level >= level) return;

    listOp[opIndex].level = level;

    DFS(producer, listOp[opIndex].node1, level + 1);
    DFS(producer, listOp[opIndex].node2, level + 1);
}

bool cmp(const Operation& a, const Operation& b) {
    return a.level > b.level;
}


void setALU(vector<pair<int, int>>& ALU) {
    // The resource amount of ALU: multiplier, adder
    ALU.push_back(make_pair(1, 1));
    ALU.push_back(make_pair(1, 2));
    ALU.push_back(make_pair(1, 3));
    ALU.push_back(make_pair(2, 1));
    ALU.push_back(make_pair(2, 2));
    ALU.push_back(make_pair(2, 3));
    ALU.push_back(make_pair(3, 1));
    ALU.push_back(make_pair(3, 2));
    ALU.push_back(make_pair(3, 3));
}

char opSymbol(int op) {
    if (op == 1) return '+';
    if (op == 3) return '-';
    if (op == 2) return '*';
    return '?';
}

int main() {
    int opCount;

    vector<pair<int, int>> ALU;
    setALU(ALU);

    ifstream in(FILE_NAME.c_str());
    if (!in.is_open()) {
        cerr << "open failed!" << endl;
        exit(EXIT_FAILURE);
    }

    in >> opCount;

    map<string, int> producer;

    for (int i = 0; i < opCount; i++) {
        int op;
        string node1, node2, result;

        in >> op >> node1 >> node2 >> result;

        producer[result] = i;
        listOp.push_back(Operation(op, node1, node2, result));
    }

    // build critical path priority
    for (int i = opCount - 1; i >= 0; i--) {
        DFS(producer, listOp[i].node1, 2);
        DFS(producer, listOp[i].node2, 2);
    }

    vector<Operation> listSaved = listOp;
    map<string, int> producerSaved = producer;

    for (int round = 0; round < ALU.size(); round++) {
        int pickCount = 1;
        vector<Operation> ready;

        listOp = listSaved;
        producer = producerSaved;

        cout << "[ALU Resource]" << endl;
        cout << "- Multiplier: " << ALU[round].first << endl;
        cout << "- Adder/Subtractor: " << ALU[round].second << endl;

        while (listOp.size() > 0 || ready.size() > 0) {
            int index = 0;

            while (index < listOp.size()) {
                if (isAvailable(producer, listOp[index].node1) &&
                    isAvailable(producer, listOp[index].node2)) {

                    ready.push_back(listOp[index]);
                    listOp.erase(listOp.begin() + index);
                }
                else {
                    index++;
                }
            }

            stable_sort(ready.begin(), ready.end(), cmp);

            int mul = ALU[round].first;
            int add = ALU[round].second; // add and sub share this resource

            cout << setw(3) << pickCount++ << " pick: ";

            int i = 0;
            while (i < ready.size() && (add > 0 || mul > 0)) {
                int nowOp = ready[i].op;

                if (nowOp == 1 || nowOp == 3) {
                    if (add <= 0) {
                        i++;
                        continue;
                    }

                    add--;

                    cout << setw(5) << ready[i].node1 << " " << opSymbol(nowOp) << " " << setw(5) << ready[i].node2 << " = " << setw(5) << ready[i].result << "   ";

                    producer.erase(ready[i].result);
                    ready.erase(ready.begin() + i);
                }
                else if (nowOp == 2) {
                    if (mul <= 0) {
                        i++;
                        continue;
                    }

                    mul--;

                    cout << setw(5) << ready[i].node1 << " * " << setw(5) << ready[i].node2 << " = " << setw(5) << ready[i].result << "   ";

                    producer.erase(ready[i].result);
                    ready.erase(ready.begin() + i);
                }
                else {
                    cerr << "unknown operation type!" << endl;
                    exit(EXIT_FAILURE);
                }
            }

            cout << endl;
        }

        cout << "Total control steps: " << pickCount - 1 << endl;
        cout << endl;
    }

    return 0;
}