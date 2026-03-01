// src/controllers/adminUserController.js
import bcrypt from "bcryptjs";
import { validationResult } from "express-validator";
import ApiError from "../utils/ApiError.js";

import {
    findUserByEmail,
    findUserByPhone,
    createUser,
} from "../models/userModel.js";

import {
    createAgent,
    getAgents,
    getAgentByUserId,
    getAgentById
} from "../models/agentModel.js";

import {
    createRider,
    getRidersByAgent,
    getAllRidersWithAgent
} from "../models/riderModel.js";

import { createCustomer } from "../models/customerModel.js";

/* --------------------------------------------------
   VALIDATION HELPER
-------------------------------------------------- */
function checkValidation(req) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        throw new ApiError(422, errors.array()[0].msg);
    }
}

/* --------------------------------------------------
   ADMIN → CREATE AGENT ACCOUNT
-------------------------------------------------- */
export const createAgentAccount = async (req, res, next) => {
    try {
        checkValidation(req);

        let {
            full_name,
            phone,
            email,
            password,
            company_name,
            area_coverage
        } = req.body;

        // FIX → convert empty email to null
        email = email?.trim() === "" ? null : email;

        if (!company_name) {
            throw new ApiError(400, "company_name is required");
        }

        // Unique email check only if actual email exists
        if (email) {
            const exists = await findUserByEmail(email);
            if (exists) throw new ApiError(400, "Email already in use");
        }

        // Unique phone check
        const phoneExists = await findUserByPhone(phone);
        if (phoneExists) throw new ApiError(400, "Phone already in use");

        const password_hash = await bcrypt.hash(password, 10);

        // Create user with role=agent
        const user = await createUser({
            full_name,
            phone,
            email,
            password_hash,
            role: "agent",
        });

        // Create agent business profile
        const agent = await createAgent({
            ownerUserId: user.id,
            company_name,
            area_coverage: area_coverage || null,
        });

        return res.status(201).json({
            success: true,
            data: { user, agent },
        });

    } catch (err) {
        next(err);
    }
};


/* --------------------------------------------------
   ADMIN → LIST ALL AGENTS
-------------------------------------------------- */
export const listAgents = async (req, res, next) => {
    try {
        const agents = await getAgents();
        return res.json({ success: true, data: agents });
    } catch (err) {
        next(err);
    }
};

/* --------------------------------------------------
   ADMIN/AGENT → CREATE RIDER ACCOUNT
-------------------------------------------------- */
export const createRiderAccount = async (req, res, next) => {
    try {
        checkValidation(req);

        const {
            full_name,
            phone,
            email,
            password,
            agent_id,
            vehicle_type,
            vehicle_number
        } = req.body;

        const requester = req.user;

        // Unique email check
        if (email) {
            const exists = await findUserByEmail(email);
            if (exists) throw new ApiError(400, "Email already in use");
        }

        // Unique phone check
        const phoneExists = await findUserByPhone(phone);
        if (phoneExists) throw new ApiError(400, "Phone already in use");

        let finalAgentId = null;

        if (requester.role === "agent") {
            // Agent creating rider → assign to their agency
            const agent = await getAgentByUserId(requester.id);
            if (!agent) throw new ApiError(400, "Agent profile missing");

            finalAgentId = agent.agent_id;

        } else if (requester.role === "admin") {

            if (!agent_id) throw new ApiError(400, "agent_id is required for admin");

            const agent = await getAgentById(agent_id);
            if (!agent) throw new ApiError(404, "Invalid agent_id");

            finalAgentId = agent_id;

        } else {
            throw new ApiError(403, "Only admin or agent can create riders");
        }

        const password_hash = await bcrypt.hash(password, 10);

        // 1️⃣ Create the rider user
        const user = await createUser({
            full_name,
            phone,
            email,
            password_hash,
            role: "rider",
            agent_id: finalAgentId,
        });

        // 2️⃣ Create rider profile
        const rider = await createRider({
            userId: user.id,
            agentId: finalAgentId,
            vehicleType: vehicle_type,
            vehicleNumber: vehicle_number,
        });

        return res.status(201).json({
            success: true,
            data: { user, rider },
        });

    } catch (err) {
        next(err);
    }
};

/* --------------------------------------------------
   ADMIN/AGENT → LIST RIDERS
-------------------------------------------------- */
export const listRiders = async (req, res, next) => {
    try {
        const requester = req.user;

        if (requester.role === "admin") {
            const riders = await getAllRidersWithAgent();
            return res.json({ success: true, data: riders });
        }

        if (requester.role === "agent") {
            const agent = await getAgentByUserId(requester.id);
            if (!agent) throw new ApiError(400, "Agent profile missing");

            const riders = await getRidersByAgent(agent.agent_id);
            return res.json({ success: true, data: riders });
        }

        throw new ApiError(403, "Not allowed");

    } catch (err) {
        next(err);
    }
};

/* --------------------------------------------------
   ADMIN/AGENT → CREATE CUSTOMER
-------------------------------------------------- */
export const createCustomerAccount = async (req, res, next) => {
    try {
        checkValidation(req);

        const { full_name, phone, email, password } = req.body;

        if (email) {
            const exists = await findUserByEmail(email);
            if (exists) throw new ApiError(400, "Email already in use");
        }

        const phoneExists = await findUserByPhone(phone);
        if (phoneExists) throw new ApiError(400, "Phone already in use");

        const password_hash = await bcrypt.hash(password, 10);

        // 1️⃣ Create customer user
        const user = await createUser({
            full_name,
            phone,
            email,
            password_hash,
            role: "customer",
            agent_id: null,
        });

        // 2️⃣ Create customer profile
        const customer = await createCustomer({ userId: user.id });

        return res.status(201).json({
            success: true,
            data: { user, customer },
        });

    } catch (err) {
        next(err);
    }
};
