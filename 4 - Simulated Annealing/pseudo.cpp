float FloorPlanning::annealing(std::string NPE0)
{

    int reject = 0;
    int N = nMoves * n;
    int MT = 1;
    int uphill = 0;
    double t0_orig = t0;
    std::string newNPE, NPE, bestNPE;
    float bestArea, newArea, NPEarea;

    bestArea = cost(NPE0); // initial state, floor plan

    NPE = NPE0;
    bestNPE = NPE0;
    NPEarea = bestArea;
    newArea = bestArea;

    std::cout << "Starting NPE" << std::endl;
    std::cout << bestNPE << std::endl
              << "\tInitial area: " << bestArea << std::endl
              << std::endl;

    if (t0 < 0)
    {
        t0 = -averageCost(NPE0) / log(P);
    } //set intial temp
    double T = t0;

    while (!(T <= epsilon) && !((reject / MT) > 0.95))
    {

        uphill = 0; // uphill moves
        reject = 0; // rejected moves
        MT = 0;     // moves
        while (!(uphill > N) && !(MT > 2 * N))
        {

            int select = rand() % 2; //select random move
            switch (select)
            {
            case 0:
                // Swap adjacent operands (ignoring chains)
                newNPE = move1(NPE);
                break;
            case 1:
                // Complement some chain
                newNPE = move2(NPE);
                break;
            case 2:
                // Swap 2 adjacent operand and operator (note that M3 can give you some invalid NPE so chacking for validity after M3 is needed)
                {
                    bool isValid = false;
                    while (!isValid)
                    {
                        newNPE = move3(NPE);
                        isValid = validNPE(newNPE);
                    }
                }
                break;
            default:
                break;
            }

            MT++; // increase moves by one

            if (cache[newNPE] == 0) // check if we have already calculated this NPE cost before, if so load from cache
            {
                newArea = cost(newNPE);
                cache[newNPE] = newArea;
            }
            else
            {
                newArea = cache[newNPE];
            }

            float dCost = newArea - NPEarea;
            if ((dCost < 0) || (((rand() % 100) / 100) < exp(-(dCost / T))))
            {
                if (dCost > 0) // if it was an uphill move
                {
                    uphill++;
                }
                // accept new expression
                NPE = newNPE;
                NPEarea = newArea;
                if (NPEarea < bestArea)
                {
                    bestArea = NPEarea; // save the best results
                    bestNPE = NPE;
                }
            }
            else // not a accepted move
            {
                reject++;
            }
        } // end inner loop
        if (T < lambdaTF * t0)
        {
            ratio = 0.1;
        }
        T *= ratio;
    }

    std::cout << "Final NPE" << std::endl;
    std::cout << bestNPE << std::endl
              << "\tFinal area: " << bestArea << std::endl
              << std::endl;

    t0 = t0_orig;
    return bestArea;
}